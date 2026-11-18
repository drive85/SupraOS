/* supra-wifi-app — SupraOS wifi popup: live list under the bars, mouse or
 * keyboard, inline PSK. Layer surface via gtk-layer-shell, styled like the
 * waybar tooltips (black, 1px-ish white border, invert on hover). */
#include <gtk/gtk.h>
#include <gtk-layer-shell.h>
#include <gdk/gdkkeysyms.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>

#define IFACE "wlan0"
#define CACHE_FMT "%s/.cache/supra-wifi/networks"

static GtkWidget *scrolled, *listbox, *psk_box, *psk_label, *psk_entry, *win, *backdrop;
static GtkWidget *info_box, *info_label;
static char current_ssid[256] = "";
static char psk_ssid[256] = "";
static char last_snapshot[8192] = "";

/* ---------- small helpers ---------- */

static char *slurp(const char *path) {
  FILE *f = fopen(path, "r");
  if (!f) return NULL;
  fseek(f, 0, SEEK_END);
  long n = ftell(f);
  fseek(f, 0, SEEK_SET);
  char *buf = malloc(n + 1);
  size_t got = fread(buf, 1, n, f);
  fclose(f);
  buf[got] = '\0';
  return buf;
}

static char *cmd_out(const char *cmd) {
  FILE *f = popen(cmd, "r");
  if (!f) return NULL;
  char buf[4096];
  size_t n = fread(buf, 1, sizeof buf - 1, f);
  pclose(f);
  buf[n] = '\0';
  return strdup(buf);
}

static void esc_xml(const char *in, char *out, size_t outsz) {
  size_t o = 0;
  for (size_t i = 0; in[i] && o + 6 < outsz; i++) {
    if (in[i] == '&') o += snprintf(out + o, outsz - o, "&amp;");
    else if (in[i] == '<') o += snprintf(out + o, outsz - o, "&lt;");
    else if (in[i] == '>') o += snprintf(out + o, outsz - o, "&gt;");
    else out[o++] = in[i];
  }
  out[o] = '\0';
}

static const char *bars_markup(int dbm, char *out, size_t sz) {
  static const char *g[4] = { "\342\226\202", "\342\226\204", "\342\226\206", "\342\226\210" };
  int lit = 1;
  if (dbm >= -55) lit = 4; else if (dbm >= -67) lit = 3; else if (dbm >= -72) lit = 2;
  out[0] = '\0';
  char tmp[256];
  for (int i = 0; i < 4; i++) {
    if (i < lit) snprintf(tmp, sizeof tmp, "%s", g[i]);
    else snprintf(tmp, sizeof tmp, "<span color='#3a3a3a'>%s</span>", g[i]);
    strncat(out, tmp, sz - strlen(out) - 1);
  }
  return out;
}

/* ---------- wifi state ---------- */

static void read_current(void) {
  current_ssid[0] = '\0';
  char *out = cmd_out("wpa_cli -i " IFACE " status 2>/dev/null");
  if (!out) return;
  char *p = strstr(out, "\nssid=");
  if (!p && strncmp(out, "ssid=", 5) == 0) p = out;
  if (p) {
    p = strchr(p, '=') + 1;
    char *e = strchr(p, '\n');
    if (e) *e = '\0';
    snprintf(current_ssid, sizeof current_ssid, "%s", p);
  }
  free(out);
}

static int is_saved(const char *ssid) {
  char *out = cmd_out("wpa_cli -i " IFACE " list_networks 2>/dev/null");
  if (!out) return 0;
  char *line = strtok(out, "\n");
  int found = 0;
  while (line) {
    char id[64] = "", name[256] = "";
    if (sscanf(line, "%63[^\t]\t%255[^\t]", id, name) == 2 && strcmp(name, ssid) == 0) { found = 1; break; }
    line = strtok(NULL, "\n");
  }
  free(out);
  return found;
}


static void run_connect(const char *ssid, const char *flags, const char *psk) {
  setenv("SUPRA_SSID", ssid, 1);
  setenv("SUPRA_FLAGS", flags ? flags : "", 1);
  if (psk) setenv("SUPRA_PSK", psk, 1); else unsetenv("SUPRA_PSK");
  char cmd[512];
  snprintf(cmd, sizeof cmd, "%s/.local/bin/supra-wifi-connect-ssid >/dev/null 2>&1", getenv("HOME"));
  int rc = system(cmd);
  (void)rc;
  gtk_main_quit();
}

/* ---------- password view ---------- */

static void show_list_view(void) {
  gtk_widget_hide(psk_box);
  if (win) gtk_window_resize(GTK_WINDOW(win), 1, 1);
  gtk_widget_hide(info_box);
  gtk_widget_show_all(scrolled);
  gtk_widget_grab_focus(listbox);
}

static void on_psk_ok(GtkButton *b, gpointer d) {
  (void)b; (void)d;
  const char *psk = gtk_entry_get_text(GTK_ENTRY(psk_entry));
  run_connect(psk_ssid, getenv("SUPRA_LAST_FLAGS"), psk);
}

static void on_psk_cancel(GtkButton *b, gpointer d) {
  (void)b; (void)d;
  show_list_view();
}

static void show_psk_view(const char *ssid, const char *flags) {
  snprintf(psk_ssid, sizeof psk_ssid, "%s", ssid);
  setenv("SUPRA_LAST_FLAGS", flags, 1);
  char t[512];
  char name[256]; esc_xml(ssid, name, sizeof name);
  snprintf(t, sizeof t, "%s", name);
  gtk_label_set_markup(GTK_LABEL(psk_label), t);
  gtk_entry_set_text(GTK_ENTRY(psk_entry), "");
  gtk_widget_hide(scrolled);
  gtk_widget_show_all(psk_box);
  if (win) gtk_window_resize(GTK_WINDOW(win), 1, 1);
  gtk_widget_grab_focus(psk_entry);
}

/* ---------- info view (connected network) ---------- */

static int signal_level(void) {
  char cmd[256];
  snprintf(cmd, sizeof cmd, "awk -v i='%s:' '$1==i{print $4}' /proc/net/wireless 2>/dev/null", IFACE);
  char *out = cmd_out(cmd);
  int lvl = -100;
  if (out) { if (out[0]) lvl = atoi(out); free(out); }
  return lvl;
}

static void field(const char *st, const char *key, char *out, size_t sz) {
  out[0] = '\0';
  char pat[64];
  snprintf(pat, sizeof pat, "%s=", key);
  const char *p = strstr(st, pat);
  if (!p) return;
  p += strlen(pat);
  const char *e = strchr(p, '\n');
  size_t n = e ? (size_t)(e - p) : strlen(p);
  if (n >= sz) n = sz - 1;
  memcpy(out, p, n);
  out[n] = '\0';
}

static void on_info_disconnect(GtkButton *b, gpointer d) {
  (void)b; (void)d;
  system("wpa_cli -i " IFACE " disconnect >/dev/null 2>&1");
  gtk_main_quit();
}

static void on_info_back(GtkButton *b, gpointer d) {
  (void)b; (void)d;
  show_list_view();
}

static void show_info_view(const char *ssid) {
  char *st = cmd_out("wpa_cli -i " IFACE " status 2>/dev/null");
  char ip[128] = "", freq[64] = "", name[256], shown[512];
  if (st) {
    field(st, "ip_address", ip, sizeof ip);
    field(st, "freq", freq, sizeof freq);
    free(st);
  }
  const char *label = (ssid && ssid[0]) ? ssid : current_ssid;
  esc_xml(label, name, sizeof name);
  esc_xml(ip[0] ? ip : "-", shown, sizeof shown);
  char mk[1400];
  snprintf(mk, sizeof mk,
    "<b>%s</b>\n\n<span color='#3a3a3a'>ip</span>      %s\n"
    "<span color='#3a3a3a'>freq</span>    %s MHz\n"
    "<span color='#3a3a3a'>signal</span>  %d dBm",
    name, shown, freq[0] ? freq : "-", signal_level());
  gtk_label_set_markup(GTK_LABEL(info_label), mk);
  gtk_widget_hide(scrolled);
  gtk_widget_hide(psk_box);
  gtk_widget_show_all(info_box);
  if (win) gtk_window_resize(GTK_WINDOW(win), 1, 1);
}

/* ---------- list ---------- */
static void on_row_activated(GtkListBox *lb, GtkListBoxRow *row, gpointer d) {
  (void)lb; (void)d;
  if (!row) return;
  const char *ssid = g_object_get_data(G_OBJECT(row), "ssid");
  const char *flags = g_object_get_data(G_OBJECT(row), "flags");
  if (!ssid) return;
  if (strcmp(ssid, current_ssid) == 0) { show_info_view(ssid); return; }
  if (is_saved(ssid)) run_connect(ssid, flags, NULL);
  else if (strstr(flags, "WPA") || strstr(flags, "RSN") || strstr(flags, "WEP")) show_psk_view(ssid, flags);
  else run_connect(ssid, flags, NULL);
}

static GtkWidget *make_row(const char *ssid, const char *flags, int dbm) {
  char bars[512], name[256];
  bars_markup(dbm, bars, sizeof bars);
  esc_xml(ssid, name, sizeof name);
  char mark[512];
  if (strcmp(ssid, current_ssid) == 0)
    snprintf(mark, sizeof mark, " <span color='#3a3a3a'>connected</span>");
  else mark[0] = '\0';
  GtkWidget *row = gtk_list_box_row_new();
  GtkWidget *lbl = gtk_label_new(NULL);
  char mk[1024];
  snprintf(mk, sizeof mk, "%s  %s%s", bars, name, mark);
  gtk_label_set_markup(GTK_LABEL(lbl), mk);
  gtk_label_set_xalign(GTK_LABEL(lbl), 0.0);
  gtk_widget_set_halign(lbl, GTK_ALIGN_FILL);
  gtk_container_add(GTK_CONTAINER(row), lbl);
  g_object_set_data_full(G_OBJECT(row), "ssid", strdup(ssid), free);
  g_object_set_data_full(G_OBJECT(row), "flags", strdup(flags), free);
  return row;
}

static void clear_children(GtkWidget *box) {
  GList *l, *ch = gtk_container_get_children(GTK_CONTAINER(box));
  for (l = ch; l; l = l->next) gtk_container_remove(GTK_CONTAINER(box), GTK_WIDGET(l->data));
  g_list_free(ch);
}

static gboolean refresh(gpointer d) {
  (void)d;
  if (gtk_widget_get_visible(psk_box) || gtk_widget_get_visible(info_box)) return G_SOURCE_CONTINUE;

  char path[512];
  snprintf(path, sizeof path, CACHE_FMT, getenv("HOME"));
  char *cache = slurp(path);
  if (!cache) return G_SOURCE_CONTINUE;

  read_current();

  char snap[8192] = "";
  snprintf(snap, sizeof snap, "cur:%s|", current_ssid);
  for (char *line = strtok(cache, "\n"); line; line = strtok(NULL, "\n")) {
    char ssid[256] = "", flags[128] = "";
    int sig = 0;
    if (sscanf(line, "%255[^\t]\t%127[^\t]\t%d", ssid, flags, &sig) == 3) {
      char one[640];
      snprintf(one, sizeof one, "%s|%s|%d|", ssid, flags, sig);
      strncat(snap, one, sizeof snap - strlen(snap) - 1);
    }
  }
  free(cache);
  if (strcmp(snap, last_snapshot) == 0) return G_SOURCE_CONTINUE;
  snprintf(last_snapshot, sizeof last_snapshot, "%s", snap);

  clear_children(listbox);
  snprintf(path, sizeof path, CACHE_FMT, getenv("HOME"));
  char *cache2 = slurp(path);
  int rows = 0;

  /* connected network first, then strongest to weakest */
  if (current_ssid[0]) {
    for (char *line = strtok(cache2, "\n"); line; line = strtok(NULL, "\n")) {
      char ssid[256] = "", flags[128] = "";
      int sig = 0;
      if (sscanf(line, "%255[^\t]\t%127[^\t]\t%d", ssid, flags, &sig) == 3
          && strcmp(ssid, current_ssid) == 0)
        { gtk_list_box_insert(GTK_LIST_BOX(listbox), make_row(ssid, flags, sig - 200), -1); rows++; }
    }
    free(cache2);
    cache2 = slurp(path);
    if (!cache2) return G_SOURCE_CONTINUE;
  }
  for (char *line = strtok(cache2, "\n"); line; line = strtok(NULL, "\n")) {
    char ssid[256] = "", flags[128] = "";
    int sig = 0;
    if (sscanf(line, "%255[^\t]\t%127[^\t]\t%d", ssid, flags, &sig) == 3
        && !(current_ssid[0] && strcmp(ssid, current_ssid) == 0))
      { gtk_list_box_insert(GTK_LIST_BOX(listbox), make_row(ssid, flags, sig - 200), -1); rows++; }
  }
  free(cache2);
  gtk_widget_show_all(listbox);
  { int vis = rows > 8 ? 8 : rows; if (vis < 1) vis = 1;
    gtk_scrolled_window_set_min_content_height(GTK_SCROLLED_WINDOW(scrolled), vis * 22);
    if (win) gtk_window_resize(GTK_WINDOW(win), 1, 1); }
  return G_SOURCE_CONTINUE;
}

static gboolean on_key(GtkWidget *w, GdkEventKey *e, gpointer d) {
  (void)w; (void)d;
  if (e->keyval == GDK_KEY_Escape) { gtk_main_quit(); return TRUE; }
  return FALSE;
}

static gboolean on_backdrop_click(GtkWidget *w, GdkEventButton *e, gpointer d) {
  (void)w; (void)e; (void)d;
  gtk_main_quit();
  return TRUE;
}

/* ---------- main ---------- */

int main(int argc, char **argv) {
  gtk_init(&argc, &argv);

  /* pidfile for the bar toggle */
  char pidpath[512];
  snprintf(pidpath, sizeof pidpath, "%s/.cache/supra-wifi/app.pid", getenv("HOME"));
  FILE *pf = fopen(pidpath, "w");
  if (pf) { fprintf(pf, "%d\n", (int)getpid()); fclose(pf); }

  /* stale cache? kick a rescan on the way in */
  char path[512], cmd[512];
  snprintf(path, sizeof path, CACHE_FMT, getenv("HOME"));
  struct stat st;
  if (stat(path, &st) != 0 || time(NULL) - st.st_mtime > 60) {
    snprintf(cmd, sizeof cmd, "%s/.local/bin/supra-wifi-rescan >/dev/null 2>&1 &", getenv("HOME"));
    system(cmd);
  }

  win = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_layer_init_for_window(GTK_WINDOW(win));
  gtk_layer_set_layer(GTK_WINDOW(win), GTK_LAYER_SHELL_LAYER_OVERLAY);
  gtk_layer_set_keyboard_mode(GTK_WINDOW(win), GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
  gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_TOP, 4);
  gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, 0);

  g_signal_connect(win, "key-press-event", G_CALLBACK(on_key), NULL);
  g_signal_connect(win, "destroy", G_CALLBACK(gtk_main_quit), NULL);

  /* transparent fullscreen catcher under the popup: any click outside closes */
  backdrop = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_layer_init_for_window(GTK_WINDOW(backdrop));
  gtk_layer_set_layer(GTK_WINDOW(backdrop), GTK_LAYER_SHELL_LAYER_TOP);
  gtk_layer_set_keyboard_mode(GTK_WINDOW(backdrop), GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
  gtk_layer_set_anchor(GTK_WINDOW(backdrop), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(backdrop), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(backdrop), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(backdrop), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
  gtk_widget_set_name(backdrop, "backdrop");
  gtk_widget_set_app_paintable(backdrop, TRUE);
  GdkVisual *vis = gdk_screen_get_rgba_visual(gdk_screen_get_default());
  if (vis) gtk_widget_set_visual(backdrop, vis);
  g_signal_connect(backdrop, "button-press-event", G_CALLBACK(on_backdrop_click), NULL);
  g_signal_connect(backdrop, "destroy", G_CALLBACK(gtk_main_quit), NULL);

  GtkWidget *frame = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
  gtk_widget_set_name(frame, "frame");
  gtk_widget_set_size_request(frame, 240, -1);
  gtk_container_add(GTK_CONTAINER(win), frame);

  listbox = gtk_list_box_new();
  gtk_list_box_set_selection_mode(GTK_LIST_BOX(listbox), GTK_SELECTION_BROWSE);
  g_signal_connect(listbox, "row-activated", G_CALLBACK(on_row_activated), NULL);
  scrolled = gtk_scrolled_window_new(NULL, NULL);
  gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolled), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC);
  gtk_widget_set_size_request(scrolled, 260, -1);
  gtk_scrolled_window_set_max_content_height(GTK_SCROLLED_WINDOW(scrolled), 176);
  gtk_container_add(GTK_CONTAINER(scrolled), listbox);
  gtk_box_pack_start(GTK_BOX(frame), scrolled, TRUE, TRUE, 0);

  /* password view */
  psk_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6);
  gtk_container_set_border_width(GTK_CONTAINER(psk_box), 10);
  psk_label = gtk_label_new("");
  gtk_label_set_xalign(GTK_LABEL(psk_label), 0.0);
  psk_entry = gtk_entry_new();
  gtk_entry_set_visibility(GTK_ENTRY(psk_entry), FALSE);
  gtk_entry_set_placeholder_text(GTK_ENTRY(psk_entry), "Password");
  GtkWidget *hbtn = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
  GtkWidget *ok = gtk_button_new_with_label("connect");
  GtkWidget *cancel = gtk_button_new_with_label("cancel");
  g_signal_connect(ok, "clicked", G_CALLBACK(on_psk_ok), NULL);
  g_signal_connect(cancel, "clicked", G_CALLBACK(on_psk_cancel), NULL);
  gtk_box_pack_end(GTK_BOX(hbtn), ok, FALSE, FALSE, 0);
  gtk_box_pack_end(GTK_BOX(hbtn), cancel, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(psk_box), psk_label, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(psk_box), psk_entry, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(psk_box), hbtn, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(frame), psk_box, FALSE, FALSE, 0);
  g_signal_connect(psk_entry, "activate", G_CALLBACK(on_psk_ok), NULL);

  /* info view (connected network) */
  info_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8);
  gtk_container_set_border_width(GTK_CONTAINER(info_box), 10);
  info_label = gtk_label_new("");
  gtk_label_set_xalign(GTK_LABEL(info_label), 0.0);
  GtkWidget *ibtns = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
  GtkWidget *idisc = gtk_button_new_with_label("disconnect");
  GtkWidget *iback = gtk_button_new_with_label("back");
  g_signal_connect(idisc, "clicked", G_CALLBACK(on_info_disconnect), NULL);
  g_signal_connect(iback, "clicked", G_CALLBACK(on_info_back), NULL);
  gtk_box_pack_end(GTK_BOX(ibtns), idisc, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(ibtns), iback, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(info_box), info_label, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(info_box), ibtns, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(frame), info_box, FALSE, FALSE, 0);

  /* same look as the waybar tooltips */
  const char *css =
    "#frame { background-color: #000000; border: 2px solid #e8e6df; }\n"
    "#backdrop { background-color: rgba(0,0,0,0); }\n"
    "window { background-color: #000000; }\n"
    "scrolledwindow { background-color: #000000; }\n"
    "viewport { background-color: #000000; }\n"
    "label { color: #e8e6df; font-family: 'DejaVu Sans Mono', monospace; font-size: 12px; }\n"
    "list { background-color: #000000; }\n"
    "list row { background-color: #000000; color: #e8e6df; padding: 2px 8px; }\n"
    "list row:hover { background-color: #e8e6df; }\n"
    "list row:hover label { color: #000000; }\n"
    "list row:selected { background-color: #e8e6df; }\n"
    "list row:selected label { color: #000000; }\n"
    "entry { background-color: #000000; background-image: none; color: #e8e6df; border: 1px solid #e8e6df; border-radius: 0; box-shadow: none; padding: 4px; }\n"
    "entry image, entry undershoot, entry progress { background-image: none; }\n"
    "button { background-color: #000000; background-image: none; color: #e8e6df; border: 1px solid #e8e6df; border-radius: 0; box-shadow: none; text-shadow: none; padding: 2px 12px; min-height: 0; }\n"
    "button:hover, button:active, button:focus, button:checked { background-color: #e8e6df; background-image: none; color: #000000; }\n"
    "button:hover label, button:active label, button:focus label { color: #000000; }\n";
  GtkCssProvider *prov = gtk_css_provider_new();
  gtk_css_provider_load_from_data(prov, css, -1, NULL);
  gtk_style_context_add_provider_for_screen(gdk_screen_get_default(),
    GTK_STYLE_PROVIDER(prov), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

  refresh(NULL);
  g_timeout_add(2000, refresh, NULL);
  gtk_widget_show_all(win);
  gtk_widget_show(backdrop);
  gtk_widget_hide(psk_box);
  gtk_widget_hide(info_box);

  /* SUPRA_WIFI_VIEW=psk|info opens that view directly (for testing) */
  const char *view = getenv("SUPRA_WIFI_VIEW");
  if (view && strcmp(view, "psk") == 0) show_psk_view("RM_IT", "[WPA2-PSK-CCMP][ESS]");
  else if (view && strcmp(view, "info") == 0) { read_current(); if (current_ssid[0]) show_info_view(current_ssid); }
  else gtk_widget_grab_focus(listbox);
  gtk_main();
  return 0;
}
