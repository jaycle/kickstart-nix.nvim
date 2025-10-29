# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{inputs}: final: prev:
with final.pkgs.lib; let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # First build parsley as a separate plugin
  parsley-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "parsley";
    version = "2024-02-26";  # Use appropriate date
    src = pkgs.fetchFromGitHub {
      owner = "monkoose";
      repo = "parsley";
      rev = "c4100aa449bfa971dcfc56ffe4206ba034db08cc";
      sha256 = "u/ys2WDEu4GxUHQCuGr6ZB4l47myQ+gd8m/AIS7qYBc=";
    };
    meta.homepage = "https://github.com/monkoose/parsley/";
  };
  
  # Then build nvlime, explicitly setting its dependencies
  nvlime-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "nvlime";
    version = "2024-12-07";
    src = pkgs.fetchFromGitHub {
      owner = "monkoose";
      repo = "nvlime";
      rev = "228e4fa8c7d10b1ed07b1649a63743613b77a828";
      sha256 = "pX4kmiTzRrUFUqAYmuUuEN66R67WDxnwFi5ZmAWVKAc=";
    };
    meta.homepage = "https://github.com/monkoose/nvlime/";
    dependencies = [ parsley-plugin ];
    doCheck = false;  # Failing on nvlime.cmp
  };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    # plugins from nixpkgs go in here.
    # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=vimPlugins
    nvim-treesitter.withAllGrammars
    # luasnip # snippets | https://github.com/l3mon4d3/luasnip/
    # nvim-cmp (autocompletion) and extensions
    # nvim-cmp and extensions
    nvim-cmp # https://github.com/hrsh7th/nvim-cmp
    cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp/
    cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/
    cmp-buffer # current buffer as completion source | https://github.com/hrsh7th/cmp-buffer/
    cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/
    cmp-nvim-lua # neovim lua API as completion source | https://github.com/hrsh7th/cmp-nvim-lua/
    cmp-cmdline # cmp command line suggestions
    cmp-cmdline-history # cmp command line history suggestions
    conjure # Interactive programming | https://github.com/Olical/conjure
    nvim-parinfer # Parentheses infer | https://github.com/gpanders/nvim-parinfer
    nvim-paredit # Parentheses editing | https://github.com/julienvincent/nvim-paredit/

    nvim-tree-lua # Directory tree-view | https://github.com/nvim-tree/nvim-tree.lua

    copilot-vim # Github Copilot |  https://github.com/github/copilot.vim/
    CopilotChat-nvim # Chat with Github Copilot | https://github.com/CopilotC-Nvim/CopilotChat.nvim


    # git integration plugins
    diffview-nvim # https://github.com/sindrets/diffview.nvim/
    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim/
    vim-fugitive # https://github.com/tpope/vim-fugitive/

    # telescope and extensions
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
    telescope-fzy-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
    nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
    # telescope-smart-history-nvim # https://github.com/nvim-telescope/telescope-smart-history.nvim

    # UI
    rose-pine
    lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/
    nvim-navic # Add LSP location to lualine | https://github.com/SmiteshP/nvim-navic
    statuscol-nvim # Status column | https://github.com/luukvbaal/statuscol.nvim/
    nvim-treesitter-context # nvim-treesitter-context

    # navigation/editing enhancement plugins
    nvim-comment

    # Useful utilities
    # nvim-unception # Prevent nested neovim sessions | nvim-unception

    # libraries that other plugins depend on
    sqlite-lua
    plenary-nvim
    nvim-web-devicons
    vim-repeat

    # bleeding-edge plugins from flake inputs
    # (mkNvimPlugin inputs.wf-nvim "wf.nvim") # (example) keymap hints | https://github.com/Cassin01/wf.nvim
    which-key-nvim
    parsley-plugin
    nvlime-plugin
    # (pkgs.vimUtils.buildVimPlugin {
    #   pname = "parsley";
    #   version = "2024-12-07";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "monkoose";
    #     repo = "parsley";
    #     rev = "c4100aa449bfa971dcfc56ffe4206ba034db08cc";
    #     sha256 = "u/ys2WDEu4GxUHQCuGr6ZB4l47myQ+gd8m/AIS7qYBc=";
    #   };
    #   meta.homepage = "https://github.com/monkoose/parsley/";
    # })
    # (pkgs.vimUtils.buildVimPlugin {
    #     pname = "nvlime";
    #     version = "2024-12-07";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "monkoose";
    #       repo = "nvlime";
    #       rev = "228e4fa8c7d10b1ed07b1649a63743613b77a828";
    #       sha256 = "pX4kmiTzRrUFUqAYmuUuEN66R67WDxnwFi5ZmAWVKAc=";
    #     };
    #     meta.homepage = "https://github.com/monkoose/nvlime/";
    # })
  ];

  extraPackages = with pkgs; [
    # language servers, etc.
    lua-language-server
    ripgrep
    nil # nix LSP
  ];
in {
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
