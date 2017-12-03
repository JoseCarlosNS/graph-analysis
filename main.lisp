(load "graph.lisp")
(load "tgf-io.lisp")
(load "metrics.lisp")

(let ((option nil))
    (loop
        (format t "What do you want to do?
            1- Load and analyse an graph from disk.
            2- Generate a single random graph and analyse it.
            3- Generate lots of random graphs and get average metrics. 
            0- Exit~%")
        (finish-output)
        (setf option (read))
        (if (numberp option)
            (case option
                (0  (return nil))
                (1  (let ((graph nil) (archive nil) (graph-type nil) (nodes-first nil) (connected nil))
                        (format t "Type the name of the archive (must be in current directory):~%")
                        (finish-output)
                        (setf archive (read-line))
                        (loop
                            (format t "Type of graph:~t1- Directed~t2- Undirected~%")
                            (setf graph-type (read))
                            (if (and (numberp graph-type) (or (= 1 graph-type) (= 2 graph-type)))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (format t "Node ids first?~%")
                        (finish-output)
                        (setf nodes-first (read))
                        (setf archive (merge-pathnames archive))
                        (setf graph (load-tgf archive :g-type graph-type))
                        (setf connected (run-analysis graph :verbose t))
                        (print-graph-info graph :verbose connected)))
                (2  (let ((graph nil) (number-of-nodes nil) (graph-type nil) (edge-prob nil) (connected nil))
                        (loop 
                            (format t "Number of nodes:~%")
                            (finish-output)
                            (setf number-of-nodes (read))
                            (if (and (numberp number-of-nodes) (> number-of-nodes 0))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (loop 
                            (format t "Type of graph: ~t1- Directed ~t2- Undirected~%")
                            (finish-output)
                            (setf graph-type (read))
                            (if (and (numberp number-of-nodes) (or (= 1 graph-type) (= 2 graph-type)))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (loop 
                            (format t "Probability of link (float between 0 and 100):~%")
                            (finish-output)
                            (setf edge-prob (read))
                            (if (and (numberp number-of-nodes) (or (>= edge-prob 0) (<= edge-prob 100)) )
                                (return nil)
                                (format t "Invalid input!~%")))
                        (setf graph (random-graph number-of-nodes graph-type edge-prob :verbose t))
                            (setf connected (run-analysis graph :verbose t))
                            (print-graph-info graph :verbose connected)))
                (3  (let ((number-of-graphs nil) (number-of-nodes nil) (graph-type nil) (option nil) (model nil) (results nil))
                        (loop 
                            (format t "Number of graphs generated per iteration:~%")
                            (finish-output)
                            (setf number-of-graphs (read))
                            (if (and (numberp number-of-graphs) (> number-of-graphs 0))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (loop 
                            (format t "Number of nodes:~%")
                            (finish-output)
                            (setf number-of-nodes (read))
                            (if (and (numberp number-of-nodes) (> number-of-nodes 0))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (loop 
                            (format t "Graph type:~%")
                            (finish-output)
                            (setf graph-type (read))
                            (if (and (numberp graph-type) (> graph-type 0) (< graph-type 3))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (loop 
                            (format t "Model of random graph:~%~t1-Erdös and Rényi.~t2-Small World.~t3-Scale-free.~%")
                            (finish-output)
                            (setf model (read))
                            (if (and (numberp model) (> model 0) (< model 4))
                                (return nil)
                                (format t "Invalid input!~%")))
                        (case model
                            (1  (progn   
                                    (setf results (metrics-random-graph number-of-graphs number-of-nodes graph-type :verbose t))))
                            (2  (let ((initial-degree nil))              
                                    (loop 
                                        (format t "Initial degree:~%")
                                        (finish-output)
                                        (setf initial-degree (read))
                                        (if (and (numberp initial-degree) (> initial-degree 0) (< model (1- number-of-nodes)))
                                            (return nil)
                                            (format t "Invalid input!~%")))
                                    (setf results (metrics-small-world number-of-graphs number-of-nodes graph-type initial-degree :verbose t))))
                            (3  (setf results (metrics-scale-free number-of-graphs number-of-nodes graph-type :verbose t))))
                        (let ((savep nil))
                            (format t "Do you want to save the data to a file?~t1- Yes.~t2- No.~%")
                            (finish-output)
                            (setf savep (read))
                            (when (numberp savep)
                                (case savep
                                    (1  (let ((file-name nil) (metric nil))
                                        (format t "Name of the file:~%Obs.: It will be saved in current directory in different files. The metrics analysed will be appended to the file name.~%")
                                        (finish-output)
                                        (setf file-name (read-line))
                                        (loop for data in results and index from 0 do
                                            (case index
                                                (0 (setf metric "-average_diameter.txt"))
                                                (1 (setf metric "-connectedness.txt"))
                                                (2 (setf metric "-distance.txt"))
                                                (3 (setf metric "-efficiency.txt"))
                                                (4 (if  (= 1 graph-type) 
                                                        (progn
                                                            (setf metric "-degree_distribution_out.txt")
                                                            (save-data (first data) (concatenate 'string file-name metric))
                                                            (setf data (second data))
                                                            (setf metric "-degree_distribution_in.txt"))
                                                        (setf metric "-degree_distribution.txt"))))
                                            (save-data data (concatenate 'string file-name metric)))))))))))
            (format t "Invalid input!~%"))))
