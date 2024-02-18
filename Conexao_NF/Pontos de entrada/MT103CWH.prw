#Include "Protheus.ch"

/*/{Protheus.doc} MT103CWH
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para bloquear o cabeçalho do documento de entrada 
durante a última etapa da importação
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT103CWH()
Local lRet := .T.

	//If
	//	Regra existente
	//	[...]
	//EndIf

	If lRet
		// Ponto de chamada ConexãoNF-e sempre como última instrução.
		lRet := U_GTPE006() 
	EndIf

Return lRet
