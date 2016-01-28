(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set the load path  

;; add everything under ~/.emacs.d/lisp to it
(let* ((my-lisp-dir "~/.emacs.d/lisp")
       (default-directory my-lisp-dir))
  (setq load-path (cons my-lisp-dir load-path))
  (normal-top-level-add-subdirs-to-load-path))

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
             '("marmalade" . "https://marmalade-repo.org/packages/"))
;; FIXME: am I *ever* going to use ancient Emacs again?
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; put all emacs droppings in local directory
(setq backup-directory-alist '(("." . "~/.emacs.d/BACKUPS")))

(add-to-list 'auto-mode-alist '("\\.pyw\\'" . python-mode))
;; Clojure
(setq auto-mode-alist (cons '("\\.edn$" . clojure-mode) auto-mode-alist))  ; *.edn are Clojure files
(setq auto-mode-alist (cons '("\\.cljs$" . clojure-mode) auto-mode-alist)) ; *.cljs are Clojure files
(setq auto-mode-alist (cons '("\\.cljc$" . clojure-mode) auto-mode-alist)) ; *.cljc are Clojure files

(setq initial-scratch-message
      ";; scratch buffer created -- happy hacking\n")

(put 'narrow-to-region 'disabled nil) ;; enable...
(put 'erase-buffer 'disabled nil)     ;; ... useful things
(file-name-shadow-mode t) ;; be smart about filenames in mbuf

(setq inhibit-startup-message t		   ;; don't show ...    
      inhibit-startup-echo-area-message t) ;; ... startup messages
(setq require-final-newline t)		   ;; end files with a newline

(display-time-mode)
(beacon-mode)
(global-prettify-symbols-mode)
;; Handy S-expression tools. Paredit is wonderful, once you get the hang of it...
(show-paren-mode)
(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'nrepl-interaction-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)

;; Turn off IDO Mode. Call me old-school
(setq ido-enable-flex-matching nil)
(setq ido-everywhere nil)
(setq ido-create-new-buffer 'always)
(ido-mode 0)

;; key board / input method settings
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")       ; prefer utf-8 for language settings
(set-input-method nil)                   ; no funky input for normal editing;
(setq read-quoted-char-radix 10)         ; use decimal, not octal
(sml/setup)

(defun tdd-test ()
  "Thin wrapper around `cider-test-run-tests'."
  (when (cider-connected-p)
    (let ((cider-auto-select-test-report-buffer nil)
          (cider-test-show-report-on-success nil))
      (cider-test-run-tests nil))))

(define-minor-mode tdd-mode
  "Run all tests whenever a file is saved."
  t nil nil
  :global t
  (if tdd-mode
      (add-hook 'cider-file-loaded-hook #'tdd-test)
    (remove-hook 'cider-file-loaded-hook #'tdd-test)))

(defun gjbroom/go-mode-hook ()
  ; Call Gofmt before saving                                                    
  (add-hook 'before-save-hook 'gofmt-before-save)
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))
  ; Godef jump key binding                                                      
  (local-set-key (kbd "M-.") 'godef-jump))
(add-hook 'go-mode-hook 'gjbroom/go-mode-hook)
