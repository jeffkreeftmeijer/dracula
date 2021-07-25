(require 'ox-publish)
(require 'ox-html-clean)
(require 'templatel)

(setq org-export-with-smart-quotes t)
(setq org-html-htmlize-output-type 'css)

(defun org-dracula-html-template (contents info)
  (let ((template (plist-get info :html-template)))
    (if template
	(templatel-render-string template `(("title" . ,(org-export-data (plist-get info :title) info))
					    ("subtitle" . ,(org-export-data (plist-get info :subtitle) info))
					    ("date" . ,(org-export-data (org-export-get-date info) info))

					    ("date_updated" . ,(let ((file (plist-get info :input-file)))
								 (format-time-string
								  "%Y-%m-%d"
								  (if file (nth 5 (file-attributes file)) (current-time)))))
					    ("contents" . ,contents)
					    ("head" . ,(org-element-normalize-string (plist-get info :html-head)))
					    ("author" . ,(org-element-interpret-data
							  (org-element-map (plist-get info :author)
							      (cons 'plain-text org-element-all-objects)
							    'identity info)))
					    ("description" . ,(plist-get info :description))
					    ("home" . ,(plist-get info :html-link-home))
					    ("path" . ,(plist-get info :html-path))
					    ("twitter" . ,(plist-get info :twitter))))
      (org-html-template contents info))))

(defun org-dracula-html-section (section contents info)
  (or contents ""))

(defun org-dracula-html-headline (headline contents info)
  "Transcode a HEADLINE element from Org to HTML.
CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  (unless (org-element-property :footnote-section-p headline)
    (let* ((numberedp (org-export-numbered-headline-p headline info))
           (numbers (org-export-get-headline-number headline info))
           (level (+ (org-export-get-relative-level headline info)
                     (1- (plist-get info :html-toplevel-hlevel))))
           (todo (and (plist-get info :with-todo-keywords)
                      (let ((todo (org-element-property :todo-keyword headline)))
                        (and todo (org-export-data todo info)))))
           (todo-type (and todo (org-element-property :todo-type headline)))
           (priority (and (plist-get info :with-priority)
                          (org-element-property :priority headline)))
           (text (org-export-data (org-element-property :title headline) info))
           (tags (and (plist-get info :with-tags)
                      (org-export-get-tags headline info)))
           (full-text (funcall (plist-get info :html-format-headline-function)
                               todo todo-type priority text tags info))
           (contents (or contents ""))
	   (id (org-html--reference headline info))
	   (formatted-text
	    (if (plist-get info :html-self-link-headlines)
		(format "<a href=\"#%s\">%s</a>" id full-text)
	      full-text)))
      (if (org-export-low-level-p headline info)
          ;; This is a deep sub-tree: export it as a list item.
          (let* ((html-type (if numberedp "ol" "ul")))
	    (concat
	     (and (org-export-first-sibling-p headline info)
		  (apply #'format "<%s class=\"org-%s\">\n"
			 (make-list 2 html-type)))
	     (org-html-format-list-item
	      contents (if numberedp 'ordered 'unordered)
	      nil info nil
	      (concat (org-html--anchor id nil nil info) formatted-text)) "\n"
	     (and (org-export-last-sibling-p headline info)
		  (format "</%s>\n" html-type))))
	;; Standard headline.  Export it as a section.
	(let ((headline-class
	       (org-element-property :HTML_HEADLINE_CLASS headline))
	      (first-content (car (org-element-contents headline))))
	  (concat
	   (format "\n<h%d id=\"%s\"%s>%s</h%d>\n"
		   level
		   id
		   (if (not headline-class) ""
		     (format " class=\"%s\"" headline-class))
		   (concat
		    (and numberedp
			 (format
			  "<span class=\"section-number-%d\">%s</span> "
			  level
			  (concat (mapconcat #'number-to-string numbers ".") ".")))
		    formatted-text)
		   level)
	   ;; When there is no section, pretend there is an
	   ;; empty one to get the correct <div
	   ;; class="outline-...> which is needed by
	   ;; `org-info.js'.
	   (if (eq (org-element-type first-content) 'section) contents
	     (concat (org-html-section first-content "" info) contents))
	   ))))))

(org-export-define-derived-backend 'dracula-html 'html-clean
  :options-alist '((:html-template "HTML_TEMPLATE" nil nil newline)
		   (:html-path "HTML_PATH" nil nil nil)
		   (:twitter "TWITTER" nil nil nil))
  :translate-alist '((template . org-dracula-html-template)
		     (section . org-dracula-html-section)
		     (headline . org-dracula-html-headline)))

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
