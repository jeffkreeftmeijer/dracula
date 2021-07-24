(require 'ox-publish)
(require 'ox-html-clean)
(require 'templatel)

(defun org-dracula-html-template (contents info)
  (let ((template (plist-get info :html-template)))
    (if template
	(templatel-render-string template `(("title" . ,(org-export-data (plist-get info :title) info))
					    ("contents" . ,contents)
					    ("description" . ,(plist-get info :description))))
      (org-html-template contents info))))

(org-export-define-derived-backend 'dracula-html 'html-clean
  :options-alist '((:html-template "HTML_TEMPLATE" nil nil newline))
  :translate-alist '((template . org-dracula-html-template)))

(defun org-dracula-html-publish-to-html (plist filename pub-dir)
  (advice-add 'org-export-output-file-name
              :around #'html-clean-create-index-folder)
  (org-publish-org-to 'dracula-html filename
                      (concat "." (or (plist-get plist :html-extension)
                                      org-html-extension "html"))
                      plist pub-dir)
  (advice-remove 'org-export-output-file-name
                 #'html-clean-create-index-folder))

(setq org-publish-project-alist
      '(
	("dracula-html"
	 :base-directory "."
	 :base-extension "org"
	 :publishing-directory "_output"
	 :recursive t
	 :publishing-function org-dracula-html-publish-to-html
	 :html-doctype "html5"
	 :html-head-include-default-style nil
	 :html-head-include-scripts nil
	 :html-html5-fancy t
	 :section-numbers nil
	 :with-toc nil)))

(provide 'dracula)
