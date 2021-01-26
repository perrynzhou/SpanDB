#workloads=("microbench.spec")
#workloads=("microbench.spec" "workloada.spec" "workloada.uniform.spec" "workloadb.spec" "workloade.spec" "workloadf.spec")
#workloads=("microbench.spec" "workloada.spec" "workloada.uniform.spec" "workloadb.spec" "workloade.spec" "workloadf.spec")
#workloads=("workloadb2tb.spec")
#workloads=("workloada1tb.spec" "workloadb1tb.spec")
#workloads=("workloadb512gb.spec" "workloada1tb.spec")
#workloads=("microbench2tb.spec" "workloada2tb.spec" "workloadb2tb.spec")
#workloads=("microbench32b.spec" "microbench128b.spec" "microbench512b.spec")
#workloads=("workloada512gb.spec" "workloada1tb.spec" "workloada2tb.spec")
#workloads=("workloada512gb.uniform.spec" "workloadb512gb.spec" "workloadb512gb.uniform.spec")
#workloads=("microbench.spec" "workloada.spec" "workloada.uniform.spec" "workloadb.spec" "workloadb.uniform.spec")
#workloads=("microbench.uniform.spec")
#workloads=("insert.spec")
#workloads=("workloada.spec")
#workloads=("write0_512gb.spec" "write30_512gb.spec" "write70_512gb.spec" "write100_512gb.spec")
#("workloadb512gb.spec" "workloade512gb.spec" "workloadf512gb.spec")
#workloads=("microbench512gb.spec" "workloada512gb.spec" "workloadb512gb.spec")
workloads=("microbench.spec")
#workloads=("workloadb512gb.spec" "workloadc512gb.spec" "workloade512gb.spec" "workloadf512gb.spec")

data_dir=("nvme2")

#log_dir=("nologging" "ramdisk" "nvme1" "optane")
log_dir=("nvme2")

memorys=("1")
# memorys=("1")

#dbnames=("rocksdb" "logsdb_pl" "logsdb_ll0" "logsdb_l0" "rocksdb_split")
dbnames=("rocksdb")

ulimit -n 100000

rocksdb_base="/home/spdk/optane/rocksdb/data"
# rocksdb_base="/home/spdk/nvme/rocksdb_bak"
# rocksdb_base_512gb="/home/spdk/sata/rocksdb_bak_512gb"
rocksdb_base_512gb="/home/spdk/nvme/rocksdb_bak_512gb"
rocksdb_base_2tb="/home/spdk/nvme/rocksdb_bak_2tb"
rocksdb_base_4kb="/home/spdk/sata/rocksdb_4kb_bak/"


for db in "${dbnames[@]}";do
  if [ "$db" == "rocksdb" -o "$db" == "rocksdb_split" ];then
    base="$rocksdb_base"
    threads=("40")
    #threads=("20" "40" "80" "100" "120")
  elif [ "$db" == "logsdb_pl" ];then
    #threads=("4" "8" "12")
    threads=("6")
    base="$rocksdb_base"
  elif [ "$db" == "logsdb_ll0" ];then
    threads=("6")
    base="$rocksdb_base"
  elif [ "$db" == "logsdb_l0" ];then
    threads=("80")
    #base="$lo_base"
    base="$rocksdb_base"
  fi
  echo "$db"
  for workload in "${workloads[@]}";do

    result=$(echo $workload | grep "512gb")
    if [[ "$result" != "" ]]
    then
      base="$rocksdb_base_512gb"
    else
      result=$(echo $workload | grep "1tb")
      if [[ "$result" != "" ]]
      then
        base="/home/spdk/sata/rocksdb_bak_1tb"
      else
        result=$(echo $workload | grep "2tb")
        if [[ "$result" != "" ]]
        then
          base="$rocksdb_base_2tb"
        else
          result=$(echo $workload | grep "200gb")
          if [[ "$result" != "" ]]
          then
            base="/home/spdk/nvme/rocksdb_bak_200gb"
          else
            result=$(echo $workload | grep "4kb")
            if [[ "$result" != "" ]]
            then
              base="$rocksdb_base_4kb"
            fi
          fi       
        fi
      fi
    fi

    echo "$workload"
    echo "-e"
    for data in "${data_dir[@]}";do
      for log in "${log_dir[@]}";do
        for t in "${threads[@]}";do
          for m in "${memorys[@]}";do

            #if [ "$data" == "nvme" -a "$log" == "nvme2" ];then
            #  continue;
            #fi

            if [ "$log" == "nologging" ];then
              outlog="nologging"
            else
              outlog="/home/spdk/""$log""/rocksdb/log"
            fi
            outdata="/home/spdk/""$data""/rocksdb/data"

            echo "$data""-""$log""-""$t""-""$m"

            isload="0"
            if [ "$db" == "logsdb_ll0" -o "$db" == "rocksdb_split" ]; then
              levels=("4")
            else
              levels=("-2")
            fi

            for i in "${levels[@]}"; do
              echo "-e"
              echo "start: ""`date '+%Y-%m-%d %H:%M:%S'`"

              # fstrim "$outdata"
              # fstrim "$outlog"
              rm "$outdata"/*
              if [ "$outlog" != "nologging" ];then
               rm "$outlog"/*
              fi
              if [ "$isload" == "0" ];then
               echo "Loading database from ""$base" to "$outdata"
               cp "$base"/* "$outdata"/
               echo "Loading finish"
              fi

              #nohup iostat -d /dev/sdb -m -t 1 > dd.io.txt 2>&1 &
              #nohup mpstat -P 7 -P 8 -P 11 -P 3 -P 0 -P 76 -P 79 1 > cpu.txt 2>&1

              output="$db""_""$workload"".txt2"
              #output="spandb_so_2tb.txt"
              #output="$db""_""$data""_""$log"".txt"
              args="workloads/""$workload"" ""$t"" ""$outdata"" ""$outlog"" ""$i"" ""$m"" ""$isload"" ""$db"
              echo "$args"
              # ./rocksdb workloads/microbench.uniform.spec 6 /home/spdk/nvme/rocksdb/data /home/spdk/optane/rocksdb/log 3 1 0 logsdb_ll0
              ./rocksdb "workloads/""$workload" "$t" "$outdata" "$outlog" "$i" "$m" "$isload" "$db"
              #>> "$output"
              #echo "-e" >> "$output"
              #echo "-e" >> "$output"
              #echo "-e" >> "$output"
              #echo "-e" >> "$output"

              #kill $(ps aux | grep 'iostat' | awk '{print $2}')
              #cp "$outdata""/LOG" "$db""_""$workload"".log2"

              sleep 10
              echo "-e"
              echo "-e"
              echo "-e"
            done
            echo "-e"
            echo "-e"
          done
        done
      done
    done
  done
done

#set args workloads/microbench.uniform.spec 6 /home/spdk/nvme/rocksdb/data /home/spdk/optane/rocksdb/log 4 1 0 logsdb_ll0
#set args workloads/workloada.spec 40 /home/spdk/sata/rocksdb/data /home/spdk/optane/rocksdb/log -2 1 0 rocksdb

#sudo find /dev/hugepages/ -name 'spdk0map_*' -type f -delete