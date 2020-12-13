# 
# TODO: This makefile needs tidying up
#
SITE1	= site1
SITE2	= site2
RPROXY	= rev_proxy
SITE_PID	= pid
LB_PID	= lb.pid
RP_PID	= rp.pid
RPROXY_PID	=
CADDYFILE	=
LB_CADDYFILE	= loadbalance.caddyfile
RP_CADDYFILE	= rev_proxy.caddyfile
RPROXY_LOG	=
LB_LOG	= lb.log
RP_LOG	= rp.log

run_lb_proxy: CADDYFILE=$(LB_CADDYFILE)
run_lb_proxy: RPROXY_PID=$(LB_PID)
run_lb_proxy: RPROXY_LOG=$(LB_LOG)
run_lb_proxy: $(RPROXY)/$(LB_PID) run_rproxy
	@ printf "Started LOAD BALANCER!\n"

run_rp_proxy: CADDYFILE=$(RP_CADDYFILE)
run_rp_proxy: RPROXY_PID=$(RP_PID)
run_rp_proxy: RPROXY_LOG=$(RP_LOG)
run_rp_proxy: $(RPROXY)/$(RP_PID) run_rproxy
	@ printf "Started MULTI-SITE REVERSE PROXY!\n"

run_site1: $(SITE1)/$(SITE_PID)

run_site2: $(SITE2)/$(SITE_PID)


stop_lb_proxy: RPROXY_PID=$(LB_PID)
stop_lb_proxy: stop_proxy
	@ printf "Stopped LOAD BALANCER!\n"

stop_rp_proxy: RPROXY_PID=$(RP_PID)
stop_rp_proxy: stop_proxy
	@ printf "Stopped MULTI-SITE REVERSE PROXY!\n"

stop_proxy: stop_site1 stop_site2
	@ printf "Stopping REVERSE PROXY\n"
	- test ! -s $(RPROXY)/$(RPROXY_PID) || kill $$(cat $(RPROXY)/$(RPROXY_PID))

stop_site1:
	@ printf "Stopping SITE 1\n"
	- test ! -s $(SITE1)/$(SITE_PID) || kill $$(cat $(SITE1)/$(SITE_PID))

stop_site2:
	@ printf "Stopping SITE 2\n"
	- test ! -s $(SITE2)/$(SITE_PID) || kill $$(cat $(SITE2)/$(SITE_PID))

run_rproxy $(RPROXY)/$(LB_PID) $(RPROXY)/$(RP_PID): $(SITE1)/$(SITE_PID) $(SITE2)/$(SITE_PID) $(RPROXY)/logs ./Makefile
	@ printf "Starting up reverse proxy\n"
	cd $(RPROXY); caddy run --config $(CADDYFILE) --adapter caddyfile --pidfile $(RPROXY_PID) --watch > ./logs/$(RPROXY_LOG) 2>&1 &

$(SITE1)/$(SITE_PID): $(SITE1)/logs ./Makefile
	@ printf "Starting up SITE 1\n"
	cd $(SITE1); caddy run --pidfile $(SITE_PID) --watch > ./logs/$(SITE1).log 2>&1 &

$(SITE2)/$(SITE_PID): $(SITE2)/logs ./Makefile
	@ printf "Starting up SITE 2\n"
	cd $(SITE2); caddy run --pidfile $(SITE_PID) --watch > ./logs/$(SITE2).log 2>&1 &

$(SITE1)/logs $(SITE2)/logs $(RPROXY)/logs:
	- test -d $@ || mkdir -p $@

# TODO: The following fails to stop the load balancer ...
clean: stop_rp_proxy stop_lb_proxy
	- test ! -d $(SITE1)/logs || rm -r $(SITE1)/logs
	- test ! -d $(SITE2)/logs || rm -r $(SITE2)/logs
	- test ! -d $(RPROXY)/logs || rm -r $(RPROXY)/logs
	- test ! -d $(RPROXY)/logs || rm -r $(RPROXY)/logs

