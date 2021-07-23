(require 'dracula)

(ert-deftest dracula-test-index-filenames ()
  "Exports as index.html files to the _output directory."
  (delete-directory "_output" t)
  (org-publish-project "dracula-html" t)
  (should (string-match-p "Dracula" (dracula-test-file-contents "_output/README/index.html"))))

(ert-deftest dracula-test-doctype ()
  "Uses the html5 doctype for published HTML files."
  (delete-directory "_output" t)
  (org-publish-project "dracula-html" t)
  (should (string-match-p "<!doctype html>" (dracula-test-file-contents "_output/README/index.html"))))

(defun dracula-test-file-contents (filename)
  "Return the contents of FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))
