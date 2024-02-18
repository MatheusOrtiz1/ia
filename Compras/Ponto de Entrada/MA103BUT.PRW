
/*
MA103BUT - ADICIONA BOTOES NA ROTINA DE DOC. DE ENTRADA
*/

USER FUNCTION MA103BUT()

LOCAL ARET := {}

Local aButtons := {} 

	// Ponto de chamada ConexãoNF-e sempre como primeira instrução.
	aButtons := U_GTPE014()

AADD( ARET,{"BUDGET",   {|| U_CONCOM01()},"Importar XML","Importar XML"} )
AADD( ARET,{"BUDGET",   {|| U_viszag()},"Protocolo","Protocolo"} )
AADD( ARET,{"BUDGET",   {|| U_ZAGDOC()},"Documentos","Documentos"} )
AADD( ARET,{"BUDGET",   {|| U_ReqContrato()},'*Req.Contrato','*Req.Contrato'} )
AADD( ARET,{'BUDGET',   {|| u_ReqContrato() }, '*Req.Contrato' })
AADD( ARET,{'BUDGET',   {|| U_CNS0001()     }, '*Refaz retenção' })
aAdd( ARET , {'*Req.Contrato', {|| u_ReqContrato() }, '*Req.Contrato' })

RETURN ARET    

User Function ZAGDOC()

Private aRotina := FWloadmenudef('MATA103')

MsDocument('SF1',SF1->(RecNo()), 2)

return .t.
