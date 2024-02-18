#Include "Protheus.ch"

/*/{Protheus.doc} MT140TOK
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para definir a variável l103Auto como .F. para o comportamento correto
das validações específicas na pré-nota.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT140TOK()
Local lRet := .T.

    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    lRet := U_GTPE011()

    // Restrição para validações não serem chamadas duas vezes ao utilizar o importador da ConexãoNF-e,
    // mantendo a chamada apenas no final do processo, quando a variavel l103Auto estiver .F.
    If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
        //If
        //	Regra existente
        //	[...]
        //EndIf
    EndIf

Return lRet 
