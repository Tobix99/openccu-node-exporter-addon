#!/bin/tclsh
load /lib/tclrega.so

set ADDON_DIR /usr/local/addons/node_exporter
set TEXTFILE_DIR ${ADDON_DIR}/textfile
set METRICS_FILE ${TEXTFILE_DIR}/hm_metrics.prom
set TEMP_FILE ${TEXTFILE_DIR}/.hm_metrics.prom.tmp

file mkdir ${TEXTFILE_DIR}

proc write_metric {fd name value help type} {
  puts $fd "# HELP ${name} ${help}"
  puts $fd "# TYPE ${name} ${type}"
  puts $fd "${name} ${value}"
}

proc log_error {msg} {
  catch { exec logger "node_exporter collector: ${msg}" }
}

while {1} {
  if {[catch {
    set fd [open ${TEMP_FILE} w]

    array set result [rega_script {
      integer _count = 0;
      string _svcId;
      object _svc;
      foreach (_svcId, dom.GetObject(ID_SERVICES).EnumUsedIDs()) {
        _svc = dom.GetObject(_svcId);
        if (_svc && _svc.AlState() == asOncoming) {
          _count = _count + 1;
        }
      }
      WriteLine(_count);
    }]
    set svc_count [string trim $result(STDOUT)]
    if {$svc_count eq ""} { set svc_count 0 }
    write_metric $fd hm_service_messages $svc_count "Active Homematic service messages" gauge

    close $fd
    file rename -force ${TEMP_FILE} ${METRICS_FILE}
  } err]} {
    log_error $err
    catch { close $fd }
    catch { file delete ${TEMP_FILE} }
  }

  after 60000
}
