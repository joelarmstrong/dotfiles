(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(setq packages-used '(magit company-anaconda company smex color-theme undo-tree expand-region ess))
(package-refresh-contents)
(dolist (package packages-used)
  (unless (package-installed-p package)
    (package-install package)))

(require 'color-theme)
(require 'ido)
(require 'magit)
(require 'smex)
(require 'undo-tree)
(require 'ess-site)

;; bind expand-region
(global-set-key "\M-o" 'er/expand-region)

;; what would possess someone to do this
(ess-toggle-underscore nil)

;; keybindings
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-c\C-r" 'revert-buffer)
(global-set-key "\C-x\C-a" 'magit-status)
(require 'ergo-movement-mode)
(ergo-movement-mode 1)

;; styles
(setq-default c-default-style "linux"
              c-basic-offset 4
              indent-tabs-mode nil)
;; display

(set-default-font "Droid Sans Mono-10")

;; backup dir
(setq
   backup-by-copying t
   backup-directory-alist
    '(("." . "~/.emacs.d/saves"))
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 5
   version-control t
   vc-make-backup-files t
   auto-save-file-name-transforms
    '((".*" "~/.emacs.d/autosaves/\\1" t)))

(make-directory "~/.emacs.d/saves" t)
(make-directory "~/.emacs.d/autosaves" t)

;; Org-mode stuff
;(require 'org-install)
(require 'org)
(setq org-log-done 'time)
(setq org-agenda-files (quote ("~/Dropbox/org")))
(setq org-directory "~/Dropbox/org")
(setq org-default-notes-file "~/Dropbox/org/notes.org")
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)
(setq org-capture-templates
      '(("t" "todo" entry (file+headline "~/Dropbox/org/notes.org" "Tasks")
           "* TODO %?\n %a")
        ("n" "note" entry (file+headline "~/Dropbox/org/notes.org" "Notes")
         "* %?\n %i\n %a")))
(setq org-completion-use-ido t)
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))
(setq org-refile-use-outline-path t)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes (quote confirm))

;; Screen is such garbage
(global-set-key "\e[1;2A" [S-up])
(global-set-key "\e[1;2B" [S-down])
(global-set-key "\e[1;2C" [S-right])
(global-set-key "\e[1;2D" [S-left])
(global-set-key "\e[1;2F" [S-end])
(global-set-key "\e[1;2H" [S-home])
(global-set-key "\e[1;5A" [C-up])
(global-set-key "\e[1;5B" [C-down])
(global-set-key "\e[1;5C" [C-right])
(global-set-key "\e[1;5D" [C-left])
(global-set-key "\e[1;5F" [C-end])
(global-set-key "\e[1;5H" [C-home])
(global-set-key "\e[1;6A" [C-S-up])
(global-set-key "\e[1;6B" [C-S-down])
(global-set-key "\e[1;6C" [C-S-right])
(global-set-key "\e[1;6D" [C-S-left])
(global-set-key "\e[1;6F" [C-S-end])
(global-set-key "\e[1;6H" [C-S-home])
(global-set-key "\e[1;3A" [A-up])
(global-set-key "\e[1;3B" [A-down])
(global-set-key "\e[1;3C" [A-right])
(global-set-key "\e[1;3D" [A-left])
(global-set-key "\e[1;3F" [A-end])
(global-set-key "\e[1;3H" [A-home])

;; autocompletion
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(global-set-key "\M-/" 'company-complete)
(setq company-idle-delay nil)
(add-to-list 'company-backends 'company-anaconda)
(add-hook 'python-mode-hook 'anaconda-mode)

;; ;; Use ido with M-x
;; (global-set-key
;;  "\M-x"
;;  (lambda ()
;;    (interactive)
;;    (call-interactively
;;     (intern
;;      (ido-completing-read
;;       "M-x "
;;       (all-completions "" obarray 'commandp))))))
(smex-initialize)
(global-set-key "\M-x" 'smex)
(global-set-key "\M-X" 'smex-major-mode-commands)

(color-theme-initialize)
(color-theme-charcoal-black)

(global-undo-tree-mode)

;; stop ido from giving up on listing files in moderately large
;; directories
(setq ido-max-directory-size 200000)
(setq ido-auto-merge-work-directories-length -1)

(show-paren-mode t)

;; magically jump to symbol in current file
(defun ido-imenu ()
  "Update the imenu index and then use ido to select a symbol to navigate to.
Symbols matching the text at point are put first in the completion list."
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '())
        (symbol-names '()))
    (flet ((addsymbols (symbol-list)
                       (when (listp symbol-list)
                         (dolist (symbol symbol-list)
                           (let ((name nil) (position nil))
                             (cond
                              ((and (listp symbol) (imenu--subalist-p symbol))
                               (addsymbols symbol))
 
                              ((listp symbol)
                               (setq name (car symbol))
                               (setq position (cdr symbol)))
 
                              ((stringp symbol)
                               (setq name symbol)
                               (setq position (get-text-property 1 'org-imenu-marker symbol))))
 
                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
    ;; If there are matching symbols at point, put them at the beginning of `symbol-names'.
    (let ((symbol-at-point (thing-at-point 'symbol)))
      (when symbol-at-point
        (let* ((regexp (concat (regexp-quote symbol-at-point) "$"))
               (matching-symbols (delq nil (mapcar (lambda (symbol)
                                                     (if (string-match regexp symbol) symbol))
                                                   symbol-names))))
          (when matching-symbols
            (sort matching-symbols (lambda (a b) (> (length a) (length b))))
            (mapc (lambda (symbol) (setq symbol-names (cons symbol (delete symbol symbol-names))))
                  matching-symbols)))))
    (let* ((selected-symbol (ido-completing-read "Symbol? " symbol-names))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (goto-char position))))
(global-set-key (kbd "C-x C-i") 'ido-imenu)

;; FIXME, TODO, BUG, HACK highlighting in comments
(add-hook 'c-mode-common-hook
               (lambda ()
                (font-lock-add-keywords nil
                 '(("\\<\\(FIXME\\|TODO\\|BUG\\|HACK\\):" 1 font-lock-warning-face t)))))

(add-hook 'haskell-mode-hook 'haskell-indentation-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)

;; are you fucking serious, python-mode?
(add-hook 'python-mode-hook
          (lambda () (electric-indent-mode -1)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(git-commit-summary-max-length 72)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-mode (quote both) nil (ido))
 '(inhibit-startup-screen t)
 '(magit-process-connection-type t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "Grey15" :foreground "Grey" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "Source Code Pro")))))

(put 'downcase-region 'disabled nil)
