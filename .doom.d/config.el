;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

(let ((nudev-emacs-path "~/dev/nu/nudev/ides/emacs/"))
  (when (file-directory-p nudev-emacs-path)
    (add-to-list 'load-path nudev-emacs-path)
    (require 'nu)))

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'auto-mode-alist '("\\.repl\\'" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.ect\\'" . html-mode))
(add-hook 'html-mode-hook #'turn-off-auto-fill)

(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir t)))))

(defun open-dotfiles ()
  "Browse the files in $DOTFILES_DIR"
  (interactive)
  (doom-project-browse (expand-file-name "~/.dotfiles")))

(defun find-in-dotfiles ()
  "Open a file somewhere in $DOTFILES_DIR via a fuzzy filename search."
  (interactive)
  (doom-project-find-file (expand-file-name "~/.dotfiles")))

(defun reverse-transpose-sexps (arg)
    (interactive "*p")
    (transpose-sexps (- arg))
    (backward-sexp (1+ arg))
    (forward-sexp 1))

(defun rg-ignoring-folders (folders)
  "ripgrep selected word in project excluding folder"
  (let ((symbol (thing-at-point 'symbol t))
        (args (mapconcat 'identity
                         (mapcar #'(lambda(folder) (concat "-g '!" folder "/*'"))
                                 folders)
                         " ")))
    (counsel-rg symbol (counsel--git-root) args)))

(setq-default evil-kill-on-visual-paste nil)

(setq
 doom-theme 'doom-molokai
 history-length 100
 indent-tabs-mode nil
 confirm-kill-emacs nil ;; disable confirmation message on exit
 mode-line-default-help-echo nil ;; disable mouse help
 mode-line-format (list
                  '(:eval (list (nyan-create))))
 show-help-function nil
 evil-multiedit-smart-match-boundaries nil

 projectile-project-search-path '("~/dev/")

 evil-split-window-below t
 evil-vsplit-window-right t

 counsel-rg-base-command "rg -i -M 1000 --no-heading --line-number --color never %s ."

 frame-title-format (setq icon-title-format  ;; set window title with "[project] filename"
                          '(""
                            (:eval
                             (format "%s - " (projectile-project-name)))
                            "%b"))

 doom-font (font-spec :family "Fira Code" :size 18)
 doom-big-font-increment 2
 evil-collection-setup-minibuffer t ;; enable minibuffer to work correctly in evil mode
)

(use-package! clj-refactor
  :after clojure-mode
  :config
  (setq cljr-warn-on-eval nil
        clojure-thread-all-but-last t
        cljr-clojure-test-declaration "[midje.sweet :refer :all]"
        cljr-magic-require-namespaces
        '(("s"   . "schema.core")
          ("th"  . "common-core.test-helpers")
          ("gen" . "common-test.generators")
          ("d-pro" . "common-datomic.protocols.datomic")
          ("ex" . "common-core.exceptions")
          ("dth" . "common-datomic.test-helpers")
          ("t-money" . "common-core.types.money")
          ("d" . "datomic.api")
          ("pp" . "clojure.pprint")
          ("init" . "postmanaux.init"))))

(use-package! clojure-mode
  :config
  (define-clojure-indent
    (fact 1)
    (facts 1)
    (flow 1)
    (fnk 1)
    (provided 1)
    (clojure.test.check/quick-check 2)
    (clojure.test.check.properties/for-all 2)
    (common-datomic.test-helpers/let-entities 2))

  (setq cider-show-error-buffer 'only-in-repl
        clj-refactor-mode 1
        yas-minor-mode 1) ; for adding require/use/import statements
  (cljr-add-keybindings-with-prefix "C-c C-c")
  (set-popup-rule! "^\\*cider-repl" :side 'right :width 0.5))

(use-package! company
  :config
  (setq company-minimum-prefix-length 3
        company-tooltip-align-annotations t
        company-show-numbers t
        company-dabbrev-downcase t))

(use-package! company-box
  :hook (company-mode . company-box-mode)
  :config
  ;; Fix <prior>/<next> on company-box
  (advice-add 'company-next-page :after #'company-box--change-line)
  (advice-add 'company-previous-page :after #'company-box--change-line)
  (advice-add 'company-search-candidates :after #'company-box--change-line)
  (advice-add 'company-filter-candidates :after #'company-box--change-line)
  (advice-add 'company-search-repeat-forward :after #'company-box--change-line)
  (advice-add 'company-search-repeat-backward :after #'company-box--change-line))

(use-package! company-lsp
  :commands company-lsp
  :config
  (setq company-lsp-async t
        company-lsp-cache-candidates t
        company-lsp-filter-candidates t))

(use-package! dart-mode
  :init
  (setq dart-sdk-path "~/flutter/bin/cache/dark-sdk/"
        lsp-dart-analysis-sdk "~/flutter/bin/cache/dart-sdk/"
        lsp-auto-guess-root t
        dart-format-on-save t))

(use-package! dart-server
  :hook ((dart-mode . dart-server)))

(use-package! flutter
  :after dart-mode
  :config
  (setq
   flutter-sdk-path (concat (getenv "HOME") "/flutter"))
  (set-popup-rule! "\\*compilation\\*" :side 'right :width 0.5))

(use-package! hover
  :after dart-mode)

(use-package! lsp-java
  :after java-mode
  :config
  (setq lsp-java-workspace-cache-dir t
        lsp-java-format-enabled t
        lsp-java-format-comments-enabled t
        lsp-java-save-action-organize-imports t
        lsp-java-save-action-organize-imports t
        lsp-java-import-gradle-enabled t
        lsp-java-import-maven-enabled t
        lsp-java-auto-build t
        lsp-java-progress-report t
        lsp-java-completion-guess-arguments t
        lsp-java-enable-file-watch t
        lsp-file-watch-ignored
        '(".idea" ".ensime_cache" ".eunit" "node_modules"
          ".git" ".hg" ".fslckout" "_FOSSIL_"
          ".bzr" "_darcs" ".tox" ".svn" ".stack-work"
          "build")))

(use-package! lsp-mode
  :hook ((clojure-mode . lsp)
         (dart-mode . lsp)
         (java-mode . lsp))
  :commands lsp
  :init
  (setq lsp-enable-indentation nil
        lsp-diagnostic-package nil
        lsp-log-io nil)
  :custom
  ((lsp-clojure-server-command '("bash" "-c" "/Users/gabriel.pinto/dev/clojure-lsp")))

  :config
  (dolist (m '(clojure-mode
               clojurec-mode
               clojurescript-mode
               clojurex-mode))
    (add-to-list 'lsp-language-id-configuration `(,m . "clojure")))
  (advice-add #'lsp-rename :after (lambda (&rest _) (projectile-save-project-buffers))))

(use-package lsp-treemacs
  :after lsp-mode
  :config
  (lsp-treemacs-sync-mode 1))

(use-package! lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-peek-enable nil
        lsp-ui-peek-list-width 60
        lsp-ui-peek-fontify 'always
        lsp-ui-peek-always-show nil))

(use-package! paredit
  :hook ((clojure-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)))

(use-package! parrot
  :config
  (setq parrot-keep-partying t)
  (parrot-mode))

(after! projectile
  (add-to-list 'projectile-project-root-files-bottom-up "pubspec.yaml")
  (add-to-list 'projectile-project-root-files-bottom-up "BUILD"))

(load! "+bindings")
