#conecta no dominio
connect('weblogic', 'welcome1', 't3://localhost:8001')
#faz o deploy
deploy('wbb-web-0.0.1','/u01/oracle/wbb-web-0.0.1.war')
#encerra o server
shutdown('AdminServer','Server',ignoreSessions='true')
#encerra o script
exit()
