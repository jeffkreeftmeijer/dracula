(require 'ox-publish)
(require 'ox-html-clean)

(setq org-publish-project-alist
      '(
	("dracula-html"
	 :base-directory "."
	 :base-extension "org"
	 :publishing-directory "_output"
	 :recursive t
	 :publishing-function org-html-clean-publish-to-html)))

(provide 'dracula)
