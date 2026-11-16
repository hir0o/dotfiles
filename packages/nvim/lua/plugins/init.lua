-- 個別の設定ファイルを持たないプラグイン
return {
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  { 'nvim-lua/plenary.nvim', lazy = true },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSInstall! typescript tsx javascript css',
    config = function()
      local treesitter = require('nvim-treesitter')

      treesitter.setup({})

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'css' },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  'mfussenegger/nvim-lint',
  'antosha417/nvim-lsp-file-operations',
  'akinsho/git-conflict.nvim',
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'Avante' },
    -- nvim-treesitter (main) の query_predicates.lua が Neovim 0.12 の match API
    -- 変更に未追従で、markdown injection 時に node:range() で落ちるため一時無効化
    enabled = false,
  },
  {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    opts = {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        use_absolute_path = true,
      },
    },
  },
  {
    'yuki-yano/vinsert.vim',
    lazy = true,
    cmd = { 'VinsertToggle', 'VinsertStart', 'VinsertStop', 'VinsertCancel' },
    dependencies = { 'vim-denops/denops.vim' },
    init = function()
      vim.g.vinsert_openai_api_key = os.getenv('OPENAI_API_KEY') or ''
      vim.g.vinsert_ffmpeg_args = { '-f', 'avfoundation', '-i', ':0' }
      vim.g.vinsert_stt_streaming_mode = 'progressive'
      vim.g.vinsert_indicator = 'virt'
      vim.g.vinsert_always_yank = true
      vim.g.vinsert_debug = false
      vim.g.vinsert_text_stream = false

      vim.keymap.set('i', '<C-.>', function()
        vim.cmd('VinsertToggle insert')
      end, { silent = true, desc = 'Vinsert Toggle' })
    end,
    config = function()
      vim.keymap.set('i', '<C-w>', function()
        local status = vim.fn['vinsert#status']()
        if status.active then
          vim.cmd('VinsertCancel')
          return ''
        end
        return '<C-w>'
      end, { expr = true, silent = true })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'VinsertComplete',
        callback = function()
          local result = vim.g.vinsert_last_completion or {}
          local body = table.concat({
            string.format('Mode: %s', result.mode or 'unknown'),
            string.format('Success: %s', tostring(result.success)),
            '',
            result.final or '(no text)',
          }, '\n')
          vim.notify(body, vim.log.levels.INFO, { title = 'vinsert' })
        end,
      })
    end,
  },
}
