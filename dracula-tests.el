(require 'dracula)

(ert-deftest dracula-test-index-filenames ()
  "Exports as index.html files to the _output directory."
  (delete-directory "_output" t)
  (org-publish-project "dracula-html" t)
  (should (file-exists-p "_output/README/index.html")))

(ert-deftest dracula-test-doctype ()
  "Uses the html5 doctype for published HTML files."
  (should (string-match-p "<!doctype html>" (dracula-test-published-file-contents))))

(ert-deftest dracula-test-default-stylesheet ()
  "Does not include the default stylesheet"
  (should (not (string-match-p "<style type=\"text/css\">" (dracula-test-published-file-contents)))))

(ert-deftest dracula-test-default-javascript ()
  "Does not include the default javascript"
  (should (not (string-match-p "<script type=\"text/javascript\">" (dracula-test-published-file-contents)))))

(ert-deftest dracula-test-table-of-contents ()
  "Does not include the table of contents"
  (should (not (string-match-p "Table of Contents" (dracula-test-published-file-contents)))))

(defun dracula-test-file-contents (filename)
  "Return the contents of FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(defun dracula-test-published-file-contents ()
  (delete-directory "_output" t)
  (org-publish-project "dracula-html" t)
  (dracula-test-file-contents "_output/README/index.html"))
