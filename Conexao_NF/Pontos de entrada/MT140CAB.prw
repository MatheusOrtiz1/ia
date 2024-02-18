#Include "Protheus.ch"

/*/{Protheus.doc} MT140CAB
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para carregar os campos de totais de despesa, frete e seguro
na importação da pré-nota.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT140CAB()
Local lRet := .T.

    //If
    //	Regra existente
    //	[...]
    //EndIf

    // Ponto de chamada ConexãoNF-e sempre como última instrução.
    If lRet
        lRet := U_GTPE009()	 
    EndIf
    
Return lRet
