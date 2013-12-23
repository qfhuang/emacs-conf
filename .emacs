;; Setting English Font
(set-face-attribute
'default nil :font "DejaVu Sans Mono")
 
;; Chinese Font
(dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
                      charset
                      (font-spec :family "Microsoft YaHei" :size 12)))
;; ibus-mode
(require 'ibus)
;; Turn on ibus-mode automatically after loading .emacs
(add-hook 'after-init-hook 'ibus-mode-on)
;; Choose your key to toggle input status:
(ibus-define-common-key ?\C-\s nil)
(global-set-key (kbd "C-\\") 'ibus-toggle) ;;通过Ctrl+\切换输入法
(setq ibus-cursor-color '("red" "blue"))
(custom-set-variables '(ibus-python-shell-command-name "python2"))

;;marmalade -- emacs lisp package achives
(add-to-list 'load-path (expand-file-name "~/.emacs.d"))
(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize) ;;24自带，好像23版本上装这个扩展，能用的包不多

;;emmet-mode
;;cd ~/.emacs.d && git clone https://github.com/smihica/emmet-mode.git
(add-to-list 'load-path (expand-file-name "~/.emacs.d/emmet-mode"))
(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook 'emmet-mode) ;; enable Emmet's css abbreviation.
(add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2))) ;; indent 2 spaces.
(setq emmet-move-cursor-between-quotes t)
(global-set-key (kbd "C-<tab>") 'emmet-expand-line)

;; yasnippet

;; cd ~/.emacs.d/plugins
;; git clone https://github.com/capitaomorte/yasnippet
;; cd yasnippet
;; git clone http://github.com/capitaomorte/yasmate
;; git clone http://github.com/AndreaCrotti/yasnippet-snippets
;; mv yasnippet-snippets snippets
(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)
(setq yas-snippet-dirs
      '("~/.emacs.d/plugins/yasnippet/yasmate/snippets" ;; the yasmate collection
        "~/.emacs.d/plugins/yasnippet/snippets"         ;; the default collection
        ))
(yas/minor-mode-on) ; 以minor mode打开，这样才能配合主mode使用

;;auto-complete 1.3.1
;;http://cx4a.org/software/auto-complete/#Latest_Stable
;;make install DIR=$HOME/.emacs.d/
(add-to-list 'load-path "~/.emacs.d/plugins/auto-complete")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
(setq ac-use-quick-help nil)
(setq ac-auto-start 4) ;; 输入4个字符才开始补全
(global-set-key "\M-/" 'auto-complete)  ;; 补全的快捷键，用于需要提前补全
;; Show menu 0.8 second later
(setq ac-auto-show-menu 0.8)
;; 选择菜单项的快捷键
(setq ac-use-menu-map t)
(define-key ac-menu-map "\C-n" 'ac-next)
(define-key ac-menu-map "\C-p" 'ac-previous)
;; menu设置为12 lines
(setq ac-menu-height 12)

;; graphviz dot-mode
;;(load-file "~/.emacs.d/graphviz-dot-mode.el")

;; c-style comment for asm-mode 
(add-hook 'asm-mode-hook 
      (lambda () (setq comment-start "/* " comment-end " */")))

;; always show line numbers    
(global-linum-mode t) 
(setq linum-format "%d")  ;set format

;;paredit-mode for scheme 
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code."
  t)

;;;;;;;;;;;;
;; Scheme 
;; sudo apt-get install racket
;;;;;;;;;;;;
(require 'cmuscheme)
(setq scheme-program-name "racket")         ;; 如果用 Petite 就改成 "petite"

;; bypass the interactive question and start the default interpreter
(defun scheme-proc ()
  "Return the current Scheme process, starting one if necessary."
  (unless (and scheme-buffer
               (get-buffer scheme-buffer)
               (comint-check-proc scheme-buffer))
    (save-window-excursion
      (run-scheme scheme-program-name)))
  (or (scheme-get-process)
      (error "No current process. See variable `scheme-buffer'")))

(defun scheme-split-window ()
  (cond
   ((= 1 (count-windows))
    (delete-other-windows)
    (split-window-vertically (floor (* 0.68 (window-height))))
    (other-window 1)
    (switch-to-buffer "*scheme*")
    (other-window 1))
   ((not (find "*scheme*"
               (mapcar (lambda (w) (buffer-name (window-buffer w)))
                       (window-list))
               :test 'equal))
    (other-window 1)
    (switch-to-buffer "*scheme*")
    (other-window -1))))

(defun scheme-send-last-sexp-split-window ()
  (interactive)
  (scheme-split-window)
  (scheme-send-last-sexp))

(defun scheme-send-definition-split-window ()
  (interactive)
  (scheme-split-window)
  (scheme-send-definition))

(add-hook 'scheme-mode-hook
  (lambda ()
    (paredit-mode 1)
    (define-key scheme-mode-map (kbd "<f5>") 'scheme-send-last-sexp-split-window)
    (define-key scheme-mode-map (kbd "<f6>") 'scheme-send-definition-split-window)))

;;pareface for scheme
(require 'parenface)
(set-face-foreground 'paren-face "DimGray")

;;sbcl+slime for common lisp
;;sudo apt-get install sbcl slime
(setq inferior-lisp-program "/usr/bin/sbcl") ; your Lisp system
(add-to-list 'load-path "/usr/share/emacs23/site-lisp/slime") ; your SLIME directory
(require 'slime) (slime-setup)


;;org-mode publish html
(require 'org-publish)
(setq org-publish-project-alist
      '(
        ("blog-notes"
         :base-directory "~/org/blog/"
         :base-extension "org"
         :publishing-directory "~/org/qfhuang.github.com/"
         :recursive t
         :publishing-function org-publish-org-to-html
         :headline-levels 4
         :section-numbers nil
         :auto-preamble t
         :auto-postamble nil
         :postamble " <div id=\"disqus_thread\"></div>
    <script type=\"text/javascript\">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'qfhuang'; // required: replace example with your forum shortname

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a href=\"http://disqus.com/?ref_noscript\">comments powered by Disqus.</a></noscript>
    <a href=\"http://disqus.com\" class=\"dsq-brlink\">comments powered by <span class=\"logo-disqus\">Disqus</span></a>
     " ; your personal postamble 好像高版本org使用html-postamble
         :auto-sitemap t                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         :author "qfhuang"
         :email "qfhuang at qq dot com"
         :style    "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/worg.css\"/>"
         )
        ("blog-static"
         :base-directory "~/org/blog/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/org/qfhuang.github.com/"
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("blog" :components ("blog-notes" "blog-static"))
        ;;
        ))
;; fontify code in code blocks
;(setq org-src-fontify-natively t)

(add-hook 'org-mode-hook
  (lambda ()
    (define-key org-mode-map (kbd "<f5>") 'org-publish-project)))

