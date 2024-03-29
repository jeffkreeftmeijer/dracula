(require 'dracula)

(ert-deftest dracula-test-index-filenames ()
  "Exports as index.html files to the _output directory."
  (dracula-test-publish-html)
  (should (file-exists-p "fixtures/_output/index.html"))
  (should (file-exists-p "fixtures/_output/hello/index.html"))
  (should (file-exists-p "fixtures/_output/foo/index.html"))
  (should (file-exists-p "fixtures/_output/bar/index.html"))
  (should (file-exists-p "fixtures/_output/bar/baz/index.html")))

(ert-deftest dracula-test-templates ()
  "Uses templates"
  (dracula-test-publish-html)
  (let ((contents (dracula-test-file-contents "fixtures/_output/template/index.html")))
    (should (string-match-p "<h1>With a template</h1>\n<p>\nThis page has a custom template.\n</p>" contents))
    (should (string-match-p "subtitle: A subtitle" contents))
    (should (string-match-p "date: 2021-07-13" contents))
    (should (string-match-p (concat "updated: " (format-time-string "%Y-%m-%d")) contents))
    (should (string-match-p "author: Alice" contents))
    (should (string-match-p "image: image.jpg" contents))
    (should (string-match-p "description: A page generated with a template" contents))
    (should (string-match-p "home: http://example.com" contents))
    (should (string-match-p "path: /template/" contents))
    (should (string-match-p "twitter: @twitter" contents))
    (should (string-match-p "acknowledgements: Thanks, Bob." contents))
    (should (string-match-p "<style></style>" contents))))

(ert-deftest dracula-test-wrapper-divs ()
  "Does not wrap sections"
  (should (not (string-match-p "<div id=\"outline-container" (dracula-test-published-file-contents))))
  (should (not (string-match-p "<div id=\"outline-text" (dracula-test-published-file-contents)))))

(ert-deftest dracula-test-unnamed-ids ()
  "Does not add ids to unnamed example blocks"
  (should (string-match-p "<pre class=\"example\">" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-links ()
  "Links to other HTML pages"
  (should (string-match-p "<a href=\"/\">index.org</a>" (dracula-test-published-file-contents)))
  (should (string-match-p "<a href=\"/template/\">template.org</a>" (dracula-test-published-file-contents)))
  (should (string-match-p "<a href=\"/foo/\">foo/index.org</a>" (dracula-test-published-file-contents)))
  (should (string-match-p "<a href=\"/bar/\">bar/bar.org</a>" (dracula-test-published-file-contents)))
  (should (string-match-p "<a href=\"/bar/baz/\">bar/baz.org</a>" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-htmlize ()
  "Styles code blocks through CSS classes"
  (should (string-match-p "<span class=\"org-string\">\"Hello from Ruby!\"</span>" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-doctype ()
  "Uses the html5 doctype for published HTML files."
  (should (string-match-p "<!doctype html>" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-doctype ()
  "Uses html5 elements."
  (should (string-match-p "</aside>" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-default-stylesheet ()
  "Does not include the default stylesheet"
  (should (not (string-match-p "<style type=\"text/css\">" (dracula-test-published-file-contents)))))

(ert-deftest dracula-test-default-javascript ()
  "Does not include the default javascript"
  (should (not (string-match-p "<script type=\"text/javascript\">" (dracula-test-published-file-contents)))))

(ert-deftest dracula-test-section-numbers ()
  "Does not include section numbers"
  (should (string-match-p ">A headline</h2>" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-table-of-contents ()
  "Does not include the table of contents"
  (should (not (string-match-p "Table of Contents" (dracula-test-published-file-contents)))))

(ert-deftest dracula-test-smart-quotes ()
  "Includes smart quotes"
  (should (string-match-p "&ldquo;Smart&rdquo; quotes." (dracula-test-published-file-contents))))

(defun dracula-test-file-contents (filename)
  "Return the contents of FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(defun dracula-test-published-file-contents ()
  (dracula-test-publish-html)
  (dracula-test-file-contents "fixtures/_output/hello/index.html"))

(defun dracula-test-publish-html ()
  (let ((root default-directory))
    (cd (concat root "fixtures"))
    (delete-directory "_output" t)
    (org-publish-project "dracula-html" t)
    (cd root)))
