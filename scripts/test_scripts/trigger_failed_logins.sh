for i in {1..10}; do
  echo "login_failure_total 100" > /var/lib/node_exporter/textfile_collector/athenaguard.prom
  sleep 10
done

