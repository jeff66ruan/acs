;; acs.el --- A front-end for codesearch

;;; Commentary:

;; 
;; 

;;; License:

;; This file is not part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:
(require 'cl) 

(defcustom acs-cindex
  "cindex"
  "Name of the codesearch cindex executable to use."
  :type 'string
  :group 'acs)

(defcustom acs-csearch
  "csearch"
  "Name of the codesearch csearch executable to use."
  :type 'string
  :group 'acs)

(require 'thingatpt) ;; thing-at-point

(defun acs-region-or-symbol-at-point ()
  "Return an active selection or the symbol at point as a
   string. "
  (cond ((use-region-p)
         (buffer-substring-no-properties (region-beginning) (region-end)))
        (t
	 (thing-at-point 'symbol))))

(defun acs (string directory)
  "Search in a given DIRECTORY or files for a given search PATTERN,
with Pattern defaulting to the symbol under point."
  (interactive (list (read-from-minibuffer "Search Pattern: " (acs-region-or-symbol-at-point))
                      (read-directory-name "Directory: ")))
  (unless (> (length string) 0)
    (error "No search pattern was given"))
  (let ((commands nil)
	(full-directory (expand-file-name directory)))
    (setq commands (list acs-csearch "-f" full-directory "-n" string))
    (setq commands (mapconcat 'shell-quote-argument commands " "))
    (shell-command commands "*codesearch*")
    (pop-to-buffer "*codesearch*")
    (compilation-mode)))

(defun acs-build-index (directory)
  "Search in a given DIRECTORY or files for a given search PATTERN,
with Pattern defaulting to the symbol under point."
  (interactive (list (read-directory-name "Directory: ")))
  (let ((commands nil)
	(full-directory (expand-file-name directory)))
    (unless (file-exists-p full-directory)
      (error "No such directory %s" default-directory))
    (setq commands (list acs-cindex full-directory))
    (setq commands (mapconcat 'shell-quote-argument commands " "))
    (shell-command commands)))

(defun acs-list-index-dir ()
  "List indexed directories."
  (interactive)
  (let ((commands nil))
    (setq commands (list acs-cindex "--list"))
    (setq commands (mapconcat 'shell-quote-argument commands " "))
    (shell-command commands)))

(defun acs-update-index ()
  "Update indexed directories."
  (interactive)
  (let ((commands nil))
    (setq commands (list acs-cindex))
    (setq commands (mapconcat 'shell-quote-argument commands " "))
    (shell-command commands)))

(defun acs-reset-index ()
  "Reset indexed directories."
  (interactive)
  (let ((commands nil))
    (setq commands (list acs-cindex "--reset"))
    (setq commands (mapconcat 'shell-quote-argument commands " "))
    (shell-command commands)))

(provide 'acs)
