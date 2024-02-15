#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "shell.ch"
#Include "sigawin.ch"
#Include "TbiConn.Ch"
#include 'fileio.ch'

User Function MTA010MNU()     

	AAdd(aRotina,{"Anexar Documentos"	,"U_MSdoc()", 0, 4,0,NIL})
           
Return()

User Function MSdoc()

Private aRotina := FWloadmenudef('MATA010')

MsDocument('SB1',SB1->(RecNo()), 4)

return .t.
