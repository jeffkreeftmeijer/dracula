(require 'ox-publish)
(require 'ox-html-clean)
(require 'templatel)

(setq org-publish-project-alist
      '(
	("dracula-html"
	 :base-directory "."
	 :base-extension "org"
	 :publishing-directory "_output"
	 :recursive t
	 :publishing-function org-html-clean-publish-to-html
	 :html-doctype "html5"
	 :html-head-include-default-style nil
	 :html-head-include-scripts nil
	 :html-html5-fancy t
	 :section-numbers nil
	 :with-toc nil)))

(provide 'dracula)
