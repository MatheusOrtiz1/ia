#Include "Protheus.ch"

/*/{Protheus.doc} MT100LOK
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para limpar a variável __cInterNet e forçar 
a apresentação dos alertas customizados durante a importação.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT140LOK()
Local lRet := .T.

	// Ponto de chamada ConexãoNF-e sempre como primeira instrução.
	lRet := U_GTPE012()
	
	If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
		//If
		//	Regra existente
		//	[...]
		//EndIf
	EndIf

Return lRet
