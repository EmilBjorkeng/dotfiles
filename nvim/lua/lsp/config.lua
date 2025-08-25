-- lsp/config.lua
local M = {}

function M.get_config(servers)
    local lua_server = servers.lua_language_server
    local cpp_server = servers.cpp_language_server
    local python_server = servers.python_language_server
    local rust_server = servers.rust_language_server
    local html_server = servers.html_language_server
    local css_server = servers.css_language_server
    local js_server = servers.js_language_server

    return {
        -- Lua Language Server Configuration
        lua_language_server = {
            cmd = { lua_server.binary_path },
            filetypes = lua_server.filetype,
            root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },

            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                        path = {
                            '?.lua',
                            '?/init.lua',
                        },
                    },
                    diagnostics = {
                        globals = {
                            'vim',
                        },
                        disable = {
                            'missing-fields',
                        },
                        severity = {
                            ['undefined-global'] = 'Warning',
                            ['lowercase-global'] = 'Information',
                        },
                    },
                    workspace = {
                        library = {
                            vim.env.VIMRUNTIME,
                            vim.fn.stdpath("config"),
                        },
                        checkThirdParty = false,
                        ignoreDir = {
                            '.git', 'node_modules', '.vscode', '.idea', 'build', 'dist', '.cache',
                        },
                        maxPreload = 5000,
                        preloadFileSize = 10000,
                    },
                    completion = {
                        callSnippet = 'Both',
                        keywordSnippet = 'Replace',
                        displayContext = 6,
                        showWord = 'Fallback',
                        postfix = '@',
                        autoRequire = true,
                        workspaceWord = true,
                    },
                    hover = {
                        viewString = true,
                        viewStringMax = 1000,
                        viewNumber = true,
                        fieldInfer = 3000,
                        enumsLimit = 5,
                        previewFields = 50,
                        expandAlias = false,
                    },
                    signatureHelp = {
                        enable = true,
                    },
                    format = {
                        enable = true,
                        defaultConfig = {
                            indent_style = 'space',
                            indent_size = '4',
                            continuation_indent_size = '4',
                            max_line_length = '100',
                            end_of_line = 'lf',
                            insert_final_newline = 'true',
                            trim_trailing_whitespace = 'true',
                            quote_style = 'single',
                            call_arg_parentheses = 'keep',
                            trailing_table_separator = 'smart',
                            space_around_table_field_list = true,
                            space_before_attribute = true,
                            space_before_function_open_parenthesis = false,
                            space_before_function_call_open_parenthesis = false,
                            space_before_closure_open_parenthesis = false,
                            table_separator_style = 'comma',
                            keep_simple_control_block_one_line = true,
                            keep_simple_function_one_line = true,
                            align_call_args = false,
                            align_function_params = true,
                            align_continuous_assign_statement = true,
                            align_continuous_rect_table_field = true,
                            align_if_branch = false,
                            break_all_list_when_line_exceed = false,
                            auto_collapse_lines = false,
                        }
                    },
                    IntelliSense = {
                        traceBeSetted = false,
                        traceFieldInject = false,
                        traceLocalSet = false,
                        traceReturn = false,
                    },
                    semantic = {
                        annotation = true,
                        enable = true,
                        keyword = false,
                        variable = true,
                    },
                    spell = {
                        'en_gb', 'no_nb',
                    },
                    telemetry = {
                        enable = false,
                    },
                    window = {
                        progressBar = true,
                        statusBar = true,
                    },
                    misc = {
                        parameters = {
                            '--log-level=warn',
                            '--locale=en-gb',
                        }
                    },
                    type = {
                        castNumberToInteger = true,
                        weakUnionCheck = false,
                        weakNilCheck = false,
                        inferParamType = true,
                        castStrict = true,
                    },
                    doc = {
                        privateName = { '^_' },
                        protectedName = { '^__' },
                        packageName = {},
                        extractReturnType = true,
                    },
                    codeLens = {
                        enable = true,
                    },
                    hint = {
                        enable = true,
                        paramName = 'All',
                        paramType = true,
                        arrayIndex = 'Auto',
                        await = true,
                        semicolon = 'SameLine',
                    },
                }
            }
        },

        -- C/C++ Language Server Configuration
        cpp_language_server = {
            cmd = {
                cpp_server.binary_path,
                '--background-index',
                '--clang-tidy',
                '--completion-style=detailed',
                '--header-insertion=iwyu',
                '--function-arg-placeholders',
                '--fallback-style=llvm',
                '--cross-file-rename',
                '--log=error',
                '--j=4',
            },
            filetypes = cpp_server.filetype,
            root_markers = {
                'compile_commands.json',
                'compile_flags.txt',
                '.clangd',
                'CMakeLists.txt',
                'Makefile',
                'configure.ac',
                'meson.build',
                '.git',
            },
            init_options = {
                clangdFileStatus = true,
                usePlaceholders = true,
                completeUnimported = true,
                semanticHighlighting = true,
            },
            capabilities = {
                textDocument = {
                    completion = {
                        completionItem = {
                            snippetSupport = true,
                            resolveSupport = {
                                properties = { 'documentation', 'detail', 'additionalTextEdits' }
                            }
                        }
                    },
                    hover = {
                        contentFormat = { 'markdown', 'plaintext' },
                    },
                    signatureHelp = {
                        signatureInformation = {
                            parameterInformation = {
                                labelOffsetSupport = true
                            }
                        }
                    }
                }
            },
            settings = {
                clangd = {
                    InlayHints = {
                        Enabled = true,
                        ParameterNames = true,
                        DeducedTypes = true,
                    },
                    Completion = {
                        AllScopes = true,
                        EnableSnippets = true,
                    },
                    Diagnostics = {
                        ClangTidy = true,
                        UnusedIncludes = true,
                    }
                }
            }
        },

        -- Python Language Server Configuration
        python_language_server = {
            cmd = { python_server.binary_path, '--stdio' },
            filetypes = python_server.filetype,
            root_markers = {
                'pyproject.toml',
                'setup.py',
                'setup.cfg',
                'requirements.txt',
                'Pipfile',
                '.git'
            },
            settings = {
                python = {
                    pythonPath = "/usr/bin/python",
                    analysis = {
                        typeCheckingMode = 'basic',
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = 'workspace',
                        extraPaths = {},
                        autoImportCompletions = true,
                        indexing = true,
                        packageIndexDepths = {
                            {
                                name = "",
                                depth = 2,
                                includeAllSymbols = true
                            }
                        }
                    },
                    linting = {
                        enabled = true,
                    }
                }
            }
        },

        -- Rust Language Server Configuration
        rust_language_server = {
            cmd = { rust_server.binary_path },
            filetypes = rust_server.filetype,
            root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                    },
                    checkOnSave = {
                        command = 'clippy',
                        extraArgs = { '--all-targets' },
                    },
                    procMacro = {
                        enable = true,
                        attributes = {
                            enable = true,
                        },
                    },
                    diagnostics = {
                        enable = true,
                        experimental = {
                            enable = true,
                        },
                        disabled = { "unresolved-proc-macro" },
                    },
                    inlayHints = {
                        bindingModeHints = { enable = true },
                        chainingHints = { enable = true },
                        typeHints = { enable = true },
                        parameterHints = { enable = true },
                        closureReturnTypeHints = { enable = true },
                        lifetimeElisionHints = { enable = 'skip_trivial' },
                    },
                    completion = {
                        addCallParenthesis = true,
                        addCallArgumentSnippets = true,
                        postfix = {
                            enable = true,
                        },
                    },
                    assist = {
                        importGranularity = 'module',
                        importPrefix = 'by_self',
                    },
                }
            }
        },

        -- HTML Language Server Configuration
        html_language_server = {
            cmd = { html_server.binary_path, '--stdio' },
            filetypes = html_server.filetype,
            root_markers = { 'index.html', 'package.json', '.git' },
            init_options = {
                configurationSection = { 'html', 'css', 'javascript' },
                embeddedLanguages = {
                    css = true,
                    javascript = true,
                },
                provideFormatter = true,
            },
            settings = {
                html = {
                    format = {
                        templating = true,
                        wrapLineLength = 120,
                        unformatted = "wbr",
                        contentUnformatted = "pre,code,textarea",
                        indentInnerHtml = false,
                        preserveNewLines = true,
                        maxPreserveNewLines = 2,
                        indentHandlebars = false,
                        endWithNewline = false,
                        extraLiners = "head,body,/html",
                        wrapAttributes = "auto"
                    },
                    hover = {
                        documentation = true,
                        references = true,
                    },
                    suggest = {
                        html5 = true,
                        angular1 = true,
                        ionic = true,
                    },
                    validate = true,
                    autoClosingTags = true,
                    mirrorCursorOnMatchingTag = true,
                }
            }
        },

        -- CSS Language Server Configuration
        css_language_server = {
            cmd = { css_server.binary_path, '--stdio' },
            filetypes = css_server.filetype,
            root_markers = { 'package.json', '.git' },
            settings = {
                css = {
                    validate = true,
                    lint = {
                        compatibleVendorPrefixes = "ignore",
                        vendorPrefix = "warning",
                        duplicateProperties = "warning",
                        emptyRulesets = "warning",
                    },
                    hover = {
                        documentation = true,
                        references = true,
                    },
                    completion = {
                        triggerPropertyValueCompletion = true,
                        completePropertyWithSemicolon = true,
                    },
                },
                scss = {
                    validate = true,
                    lint = {
                        compatibleVendorPrefixes = "ignore",
                        vendorPrefix = "warning",
                        duplicateProperties = "warning",
                        emptyRulesets = "warning",
                    },
                },
                less = {
                    validate = true,
                    lint = {
                        compatibleVendorPrefixes = "ignore",
                        vendorPrefix = "warning",
                        duplicateProperties = "warning",
                        emptyRulesets = "warning",
                    },
                }
            }
        },

        -- JavaScript / TypeScript Language Server Configuration
        js_language_server = {
            cmd = { js_server.binary_path, '--stdio' },
            filetypes = js_server.filetype,
            root_markers = {
                'package.json',
                'tsconfig.json',
                'jsconfig.json',
                'yarn.lock',
                'pnpm-lock.yaml',
                '.git'
            },
            init_options = {
                hostInfo = 'neovim',
                preferences = {
                    includeCompletionsForModuleExports = true,
                    includeCompletionsWithInsertText = true,
                    importModuleSpecifierPreference = 'non-relative',
                    allowIncompleteCompletions = true,
                    providePrefixAndSuffixTextForRename = true,
                    allowRenameOfImportPath = true,
                    includePackageJsonAutoImports = 'auto',
                },
                plugins = {
                    {
                        name = '@vue/typescript-plugin',
                        location = '',  -- Will be auto-detected if available
                        languages = { 'javascript', 'typescript', 'vue' },
                    }
                }
            },
            settings = {
                typescript = {
                    inlayHints = {
                        includeInlayParameterNameHints = 'all',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                    suggest = {
                        includeCompletionsForModuleExports = true,
                        includeAutomaticOptionalChainCompletions = true,
                    },
                    preferences = {
                        includePackageJsonAutoImports = 'auto',
                        importModuleSpecifier = 'shortest',
                    },
                },
                javascript = {
                    inlayHints = {
                        includeInlayParameterNameHints = 'all',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                    suggest = {
                        includeCompletionsForModuleExports = true,
                        includeAutomaticOptionalChainCompletions = true,
                    },
                    preferences = {
                        includePackageJsonAutoImports = 'auto',
                        importModuleSpecifier = 'shortest',
                    },
                }
            }
        }
    }
end

return M
