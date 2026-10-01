{
  lib,
  pkgs,
  ...
}:
let
  yaziPlugins = pkgs.yaziPlugins;

  yazi = pkgs.yazi.override {
    extraPackages = [
      pkgs.lazygit
      pkgs.ouch
      pkgs.mediainfo
      pkgs.imagemagick
      pkgs.gvfs
      pkgs.sshfs
      pkgs.trash-cli
      pkgs.ripdrag
      pkgs.duckdb
      pkgs.python314Packages.rich
      (lib.getBin pkgs.glib) # gio, the gvfs plugin shells out to it
    ];

    plugins = {
      git = yaziPlugins.git;
      lazygit = yaziPlugins.lazygit;
      diff = yaziPlugins.diff;
      yatline = yaziPlugins.yatline;
      yatline-githead = yaziPlugins.yatline-githead;
      smart-enter = yaziPlugins.smart-enter;
      jump-to-char = yaziPlugins.jump-to-char;
      relative-motions = yaziPlugins.relative-motions;
      bookmarks = yaziPlugins.bookmarks;
      smart-filter = yaziPlugins.smart-filter;
      smart-paste = yaziPlugins.smart-paste;
      clipboard = yaziPlugins.clipboard;
      ouch = yaziPlugins.ouch;
      mediainfo = yaziPlugins.mediainfo;
      rich-preview = yaziPlugins.rich-preview;
      chmod = yaziPlugins.chmod;
      convert = yaziPlugins.convert;
      full-border = yaziPlugins.full-border;
      nav-parent-panel = yaziPlugins.nav-parent-panel;
      toggle-pane = yaziPlugins.toggle-pane;
      yafg = yaziPlugins.yafg;
      gvfs = yaziPlugins.gvfs;
      recycle-bin = yaziPlugins.recycle-bin;
      sshfs = yaziPlugins.sshfs;
      split-tabs = yaziPlugins.split-tabs;
      drag = yaziPlugins.drag;
      compress = yaziPlugins.compress;
      bypass = yaziPlugins.bypass;
      duckdb = yaziPlugins.duckdb;
    };

    settings = {
      keymap = {
        mgr = {
          prepend_keymap = [
            # Navigation & search
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter a directory or open a file";
            }
            {
              on = "f";
              run = "plugin jump-to-char";
              desc = "Jump to a character in the preview";
            }
            {
              on = "F";
              run = "plugin smart-filter";
              desc = "Search files by name (smart)";
            }
            {
              on = [ "g" "m" ];
              run = "cd /mnt";
              desc = "Go to /mnt (mounted disks)";
            }
            {
              on = [ "g" "r" ];
              run = "cd /mnt/data";
              desc = "Go to /mnt/data";
            }
            {
              on = [ "g" "v" ];
              run = "cd /run/user/1000/gvfs";
              desc = "Go to GVFS mounts (WebDAV)";
            }
            {
              on = "p";
              run = "plugin smart-paste";
              desc = "Paste and handle conflicts";
            }

            # System clipboard integration
            {
              on = "y";
              run = [ "yank" "plugin clipboard -- --action=copy" ];
              desc = "Copy and sync to the system clipboard";
            }
            {
              on = "x";
              run = [ "yank --cut" "plugin clipboard -- --action=copy" ];
              desc = "Cut and sync to the system clipboard";
            }
            {
              on = "<C-p>";
              run = [ "plugin clipboard -- --action=paste" ];
              desc = "Paste from the system clipboard";
            }

            # Archives
            {
              on = "C";
              run = "plugin ouch";
              desc = "Compress with ouch";
            }
            {
              on = [ "c" "a" "a" ];
              run = "plugin compress";
              desc = "Archive selected files";
            }
            {
              on = [ "c" "a" "p" ];
              run = "plugin compress -p";
              desc = "Archive selected files (password)";
            }
            {
              on = [ "c" "a" "h" ];
              run = "plugin compress -ph";
              desc = "Archive selected files (password+header)";
            }
            {
              on = [ "c" "a" "l" ];
              run = "plugin compress -l";
              desc = "Archive selected files (compression level)";
            }
            {
              on = [ "c" "a" "u" ];
              run = "plugin compress -phl";
              desc = "Archive selected files (all options)";
            }

            # File operations
            {
              on = [ "c" "m" ];
              run = "plugin chmod";
              desc = "Chmod on selected files";
            }
            {
              on = [ "c" "p" ];
              run = "plugin convert -- --extension='png'";
              desc = "Convert selected files to PNG";
            }
            {
              on = [ "c" "j" ];
              run = "plugin convert -- --extension='jpg'";
              desc = "Convert selected files to JPG";
            }
            {
              on = [ "c" "w" ];
              run = "plugin convert -- --extension='webp'";
              desc = "Convert selected files to WebP";
            }

            # Git
            {
              on = [ "g" "i" ];
              run = "plugin lazygit";
              desc = "Open lazygit";
            }
            {
              on = "<C-d>";
              run = "plugin diff";
              desc = "Show diff of the selected files";
            }

            # Drag and drop
            {
              on = "<C-o>";
              run = "plugin drag";
              desc = "Drag selected files to another app";
            }

            # Bypass single-subdirectory chains
            {
              on = "<A-l>";
              run = "plugin bypass";
              desc = "Recursively enter a child directory";
            }
            {
              on = "<A-h>";
              run = "plugin bypass reverse";
              desc = "Recursively enter the parent directory";
            }

            # Bookmarks
            {
              on = "m";
              run = "plugin bookmarks save";
              desc = "Save the current position as a bookmark";
            }
            {
              on = "'";
              run = "plugin bookmarks jump";
              desc = "Jump to a bookmark";
            }
            {
              on = [ "b" "d" ];
              run = "plugin bookmarks delete";
              desc = "Delete a bookmark";
            }
            {
              on = [ "b" "D" ];
              run = "plugin bookmarks delete_all";
              desc = "Delete all bookmarks";
            }

            # Split view (dual pane)
            {
              on = "\\";
              run = "plugin split-tabs spl_toggle";
              desc = "Toggle split-tabs mode";
            }
            {
              on = "<Tab>";
              run = "plugin split-tabs spl_switch_tab";
              desc = "Switch to the other pane";
            }
            {
              on = "<F5>";
              run = [ "escape --visual" "plugin split-tabs spl_copy" ];
              desc = "Copy to the other pane";
            }
            {
              on = "<F6>";
              run = [ "escape --visual" "plugin split-tabs spl_move" ];
              desc = "Move to the other pane";
            }
            {
              on = "P";
              run = "plugin split-tabs spl_preview";
              desc = "Toggle the preview pane";
            }

            # Recycle bin
            {
              on = [ "R" "b" ];
              run = "plugin recycle-bin";
              desc = "Open Recycle Bin menu";
            }

            # Remote mounts
            {
              on = [ "M" "s" ];
              run = "plugin sshfs -- menu";
              desc = "Open SSHFS options";
            }
            {
              on = [ "M" "m" ];
              run = "plugin gvfs -- select-then-mount --jump";
              desc = "Select a device and mount it";
            }
            {
              on = [ "M" "R" ];
              run = "plugin gvfs -- remount-current-cwd-device";
              desc = "Remount the device under cwd";
            }
            {
              on = [ "M" "u" ];
              run = "plugin gvfs -- select-then-unmount";
              desc = "Select a device and unmount it";
            }
            {
              on = [ "M" "U" ];
              run = "plugin gvfs -- select-then-unmount --eject";
              desc = "Select a device and eject it";
            }
            {
              on = [ "M" "a" ];
              run = "plugin gvfs -- add-mount";
              desc = "Add a GVFS mount URI";
            }
            {
              on = [ "M" "e" ];
              run = "plugin gvfs -- edit-mount";
              desc = "Edit a GVFS mount URI";
            }
            {
              on = [ "M" "r" ];
              run = "plugin gvfs -- remove-mount";
              desc = "Remove a GVFS mount URI";
            }

            # DuckDB preview
            {
              on = "<C-h>";
              run = "plugin duckdb -1";
              desc = "Scroll DuckDB columns left";
            }
            {
              on = "<C-l>";
              run = "plugin duckdb +1";
              desc = "Scroll DuckDB columns right";
            }
            {
              on = [ "g" "o" ];
              run = "plugin duckdb -open";
              desc = "Open the file with DuckDB";
            }
            {
              on = [ "g" "u" ];
              run = "plugin duckdb -ui";
              desc = "Open the file with the DuckDB UI";
            }

            # Parent-panel navigation
            {
              on = "<C-k>";
              run = "plugin nav-parent-panel prev";
              desc = "Go to the previous sibling directory";
            }
            {
              on = "<C-j>";
              run = "plugin nav-parent-panel next";
              desc = "Go to the next sibling directory";
            }
            {
              on = "<C-Home>";
              run = "plugin nav-parent-panel first";
              desc = "Go to the first sibling directory";
            }
            {
              on = "<C-End>";
              run = "plugin nav-parent-panel last";
              desc = "Go to the last sibling directory";
            }

            # Pane toggling
            {
              on = "T";
              run = "plugin toggle-pane min-preview";
              desc = "Show or hide the preview pane";
            }

            # Fuzzy grep
            {
              on = [ "g" "/" ];
              run = "plugin yafg";
              desc = "Fuzzy find and grep (ripgrep/fzf)";
            }
          ];
        };
      };

      yazi = {
        mgr = {
          ratio = [ 1 2 5 ];
          show_hidden = true;
        };
        plugin = {
          prepend_fetchers = [
            {
              url = "*";
              run = "git";
              group = "git";
            }
            {
              url = "*/";
              run = "git";
              group = "git";
            }
          ];
          prepend_preloaders = [
            # mediainfo replaces the built-in magick/image/video preloaders
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/{subrip,postscript,illustrator,dvb.ait,vnd.adobe.illustrator,eps}";
              run = "mediainfo";
            }
            {
              url = "*.{ai,eps,ait}";
              run = "mediainfo";
            }
            # duckdb cache preloading (only the most common formats, preloaders are capped at 16 total)
            {
              url = "*.csv";
              run = "duckdb";
              multi = false;
            }
            {
              url = "*.parquet";
              run = "duckdb";
              multi = false;
            }
            # avoid freezing on slow GVFS mounts
            {
              url = "/run/user/*/gvfs/**/*";
              run = "noop";
            }
            {
              url = "/run/media/*/**/*";
              run = "noop";
            }
          ];
          prepend_previewers = [
            {
              mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
              run = "ouch --archive-icon=''";
            }
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/{subrip,postscript,illustrator,dvb.ait,vnd.adobe.illustrator,eps}";
              run = "mediainfo";
            }
            {
              url = "*.{ai,eps,ait}";
              run = "mediainfo";
            }
            # duckdb data preview
            {
              url = "*.csv";
              run = "duckdb";
            }
            {
              url = "*.tsv";
              run = "duckdb";
            }
            {
              url = "*.parquet";
              run = "duckdb";
            }
            {
              url = "*.txt";
              run = "duckdb";
            }
            {
              url = "*.xlsx";
              run = "duckdb";
            }
            {
              url = "*.db";
              run = "duckdb";
            }
            {
              url = "*.duckdb";
              run = "duckdb";
            }
            # rich-preview for text-ish formats
            {
              url = "*.md";
              run = "rich-preview";
            }
            {
              url = "*.rst";
              run = "rich-preview";
            }
            {
              url = "*.ipynb";
              run = "rich-preview";
            }
            {
              url = "*.json";
              run = "rich-preview";
            }
            # folders
            {
              url = "folder/*";
              run = "folder";
            }
            # avoid previewing files on slow GVFS mounts
            {
              url = "/run/user/*/gvfs/**/*";
              run = "noop";
            }
            {
              url = "/run/media/*/**/*";
              run = "noop";
            }
          ];
        };
      };

      # One Light, matching the wezterm color scheme
      theme = {
        app = {
          overall = { bg = "#fafafa"; };
        };

        mgr = {
          cwd = { fg = "#0997b3"; };
          find_keyword = {
            fg = "#c18401";
            bold = true;
            italic = true;
            underline = true;
          };
          find_position = {
            fg = "#a626a4";
            bg = "reset";
            bold = true;
            italic = true;
          };
          symlink_target = { italic = true; };
          marker_copied = { fg = "#50a14f"; bg = "#d9f2d9"; };
          marker_cut = { fg = "#e45649"; bg = "#fadedb"; };
          marker_marked = { fg = "#0997b3"; bg = "#d9f1f4"; };
          marker_selected = { fg = "#c18401"; bg = "#f9edd2"; };
          count_copied = { fg = "#50a14f"; bg = "reset"; };
          count_cut = { fg = "#e45649"; bg = "reset"; };
          count_selected = { fg = "#fafafa"; bg = "#c18401"; };
          border_style = { fg = "#d0d0d0"; };
        };

        tabs = {
          active = { fg = "#383a42"; bg = "#e5e5e6"; bold = true; };
          inactive = { fg = "#a0a1a7"; bg = "#f0f0f0"; };
        };

        mode = {
          normal_main = { fg = "#fafafa"; bg = "#50a14f"; bold = true; };
          normal_alt = { fg = "#50a14f"; bg = "#d9f2d9"; };
          select_main = { fg = "#fafafa"; bg = "#e45649"; bold = true; };
          select_alt = { fg = "#e45649"; bg = "#fadedb"; };
          unset_main = { fg = "#fafafa"; bg = "#e45649"; bold = true; };
          unset_alt = { fg = "#e45649"; bg = "#fadedb"; };
        };

        indicator = {
          parent = { fg = "#e5e5e6"; bg = "#383a42"; };
          current = { fg = "#fafafa"; bg = "#0184bc"; };
          preview = { underline = true; };
        };

        status = {
          perm_sep = { fg = "#d0d0d0"; };
          perm_type = { fg = "#50a14f"; };
          perm_read = { fg = "#c18401"; };
          perm_write = { fg = "#e45649"; };
          perm_exec = { fg = "#0997b3"; };
          progress_label = { bold = true; };
          progress_normal = { fg = "#50a14f"; bg = "reset"; };
          progress_error = { fg = "#e45649"; bg = "reset"; };
        };

        which = {
          border = { fg = "#0184bc"; };
          cand = { fg = "#0997b3"; };
          rest = { fg = "#a0a1a7"; };
          desc = { fg = "#a626a4"; };
          separator_style = { fg = "#d0d0d0"; };
        };

        confirm = {
          border = { fg = "#0184bc"; };
          title = { fg = "#0184bc"; };
        };

        spot = {
          border = { fg = "#0184bc"; };
          title = { fg = "#0184bc"; };
          tbl_col = { fg = "#0184bc"; };
          tbl_cell = { fg = "#c18401"; reversed = true; };
        };

        notify = {
          title_info = { fg = "#50a14f"; };
          title_warn = { fg = "#c18401"; };
          title_error = { fg = "#e45649"; };
        };

        pick = {
          border = { fg = "#0184bc"; };
          active = { fg = "#a626a4"; bold = true; };
        };

        input = { border = { fg = "#0184bc"; }; };
        cmp = { border = { fg = "#0184bc"; }; };

        tasks = {
          border = { fg = "#0184bc"; };
          hovered = { fg = "#a626a4"; bold = true; };
        };

        help = {
          border = { fg = "#0184bc"; };
          chord = { fg = "#0997b3"; };
        };

        filetype = {
          rules = [
            {
              mime = "**/image/*";
              fg = "#c18401";
            }
            {
              mime = "**/{audio,video}/*";
              fg = "#a626a4";
            }
            {
              mime = "**/application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
              fg = "#e45649";
            }
            {
              mime = "**/application/{pdf,doc,rtf}";
              fg = "#0997b3";
            }
            {
              mime = "vfs/{absent,stale}";
              fg = "#a0a1a7";
            }
            {
              url = "*";
              is = "orphan";
              bg = "#e45649";
            }
            {
              url = "*";
              is = "exec";
              fg = "#50a14f";
            }
            {
              url = "*";
              is = "dummy";
              bg = "#e45649";
            }
            {
              url = "*/";
              is = "dummy";
              bg = "#e45649";
            }
            {
              url = "*/";
              fg = "#0184bc";
            }
          ];
        };
      };
    };

    initLua = ./yazi-init.lua;
  };
in
{
  home.packages = [
    yazi
    pkgs.lazygit
    pkgs.ouch
    pkgs.mediainfo
    pkgs.imagemagick
    pkgs.gvfs
    pkgs.sshfs
    pkgs.trash-cli
    pkgs.ripdrag
    pkgs.duckdb
    pkgs.python314Packages.rich
  ];
}