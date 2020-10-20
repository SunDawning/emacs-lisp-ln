(defun earned::ln (target directory)
  "target是软链所指向的源文件或源文件夹，Specifies the path (relative or absolute) that the new link refers to.
directory是所创建的软链文件夹的名字，Creates a directory symbolic link.  Default is a file symbolic link."
  (when (and (stringp target) (stringp directory)
             (file-directory-p target))
    (when (and (file-directory-p directory)
               ;; ".", ".."
               (= (length (directory-files directory))
                  2))
      (delete-directory directory))
    (unless (file-directory-p directory)
      (let ((target (expand-file-name target))
            (directory (expand-file-name directory)))
        (if (eq system-type (quote windows-nt))
            ;; fix mklink: You do not have sufficient privilege to perform this operation.
            (let ((default-directory temporary-file-directory))
              (let ((temp-file (convert-standard-filename "earned::ln")))
                (with-temp-file temp-file
                  (insert
                   (prin1-to-string
                    `(progn
                       (shell-command-to-string
                        (format "mklink /D %S %S" ,directory ,target))
                       (delete-file ,temp-file)
                       (save-buffers-kill-terminal)))))
                (shell-command-to-string
                 (format "mshta vbscript:CreateObject(\"Shell.Application\").ShellExecute(\"%s\",\"--load %s\",\"\",\"runas\",1)(window.close)"
                         (executable-find "runemacs")
                         temp-file))))
          (when (executable-find "ln")
            (shell-command-to-string
             (format "ln -s %S %S" target directory))))))))
