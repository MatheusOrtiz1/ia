#Include "Protheus.ch"

/*/{Protheus.doc} MT140TOK
// Ponto de entrada utilizado pelo importador da Conex�oNF-e para definir a vari�vel l103Auto como .F. para o comportamento correto
das valida��es espec�ficas na pr�-nota.
@author Conex�oNF-e
@since 02/03/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT140TOK()
Local lRet := .T.

    // Ponto de chamada Conex�oNF-e sempre como primeira instru��o.
    lRet := U_GTPE011()

    // Restri��o para valida��es n�o serem chamadas duas vezes ao utilizar o importador da Conex�oNF-e,
    // mantendo a chamada apenas no final do processo, quando a variavel l103Auto estiver .F.
    If lRet .And. !FwIsInCallStack('U_GATI001') .Or. !l103Auto
        //If
        //	Regra existente
        //	[...]
        //EndIf
    EndIf

Return lRet 
