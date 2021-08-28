defmodule KeeperWeb.DDNSView do
  use KeeperWeb, :view

  def description do
    "从路由器定期发起请求更新 ip 地址"
  end

  def script do
    """
    #!/bin/sh
    ip=`ifconfig pppoe-wan|grep inet|grep -v inet6|awk '{print $2}' |tr -d "addr:"`
    curl -X PUT -d new_ip=$ip https://keeper.kenton.wang/api/ddns
    """
  end
end
