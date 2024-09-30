CREATE TABLE CONSINCO.NAGT_EMAILCOMPRADORES 

       (COMPRADOR VARCHAR(30), 
            EMAIL VARCHAR(50));    
             
INSERT INTO  CONSINCO.NAGT_EMAILCOMPRADORES VALUES ('VICTOR', 'email@email.com.br;email@email.com.br');
COMMIT;
             
CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_EMAILAUTO_LOTECOMPRAS AS

BEGIN
   FOR t IN (SELECT SEQLOTEMODELO, C.COMPRADOR, G.DESCRITIVO, NOMERAZAO FORNECEDOR,
                    DATA_VALIDA, HORAMIN, NVL(A.EMAIL||CASE WHEN E.EMAIL IS NULL THEN NULL ELSE ';' END||E.EMAIL, 'X') EMAIL
               FROM CONSINCO.NAGV_BUSCADTAPEDIDO D LEFT JOIN CONSINCO.MAC_GERCOMPRA G ON G.SEQGERCOMPRA = D.SEQLOTEMODELO AND G.TIPOLOTE = 'M'
                                                  INNER JOIN CONSINCO.GE_PESSOA     P ON P.SEQPESSOA    = G.SEQFORNECPRINCIPAL
                                                  INNER JOIN CONSINCO.MAX_COMPRADOR C ON C.SEQCOMPRADOR = G.SEQCOMPRADOR
                                                   LEFT JOIN CONSINCO.NAGT_EMAILCOMPRADORES A ON A.COMPRADOR = C.APELIDO
                                                   LEFT JOIN CONSINCO.NAGT_EMAILCOMPRADORES E ON E.COMPRADOR = D.ASSISTENTE AND E.COMPRADOR != A.COMPRADOR

              WHERE 1=1
                AND TRUNC(SYSDATE) = D.DATA_VALIDA - 1)
 LOOP
   BEGIN
      CONSINCO.SP_ENVIA_EMAIL(CONSINCO.C5_TP_PARAM_SMTP(1),
         /*Destinatarios*/  T.EMAIL||';',                                                                                                             
                            'Info | Programação de Geração de Lote de Compras - Fornec: '|| T.FORNECEDOR,                                 
                          '<HTML>
                            <strong>Lembrete:</strong>                                 <br/>
                            <p>Amanhã ('||TO_CHAR(T.DATA_VALIDA, 'DD/MM/YYYY')||') às '||T.HORAMIN||
                           ' hrs será gerado um Lote de Compras para o seguinte fornecedor:        <br/>
                            <p> - Fornecedor: '||T.FORNECEDOR||'                          <br/>
                             - Comprador no Lote: '||INITCAP(LOWER(T.COMPRADOR))||'       <br/>
                             - Lote Modelo: '||T.SEQLOTEMODELO||'                         <br/>
                             - Programação: '||TO_CHAR(T.DATA_VALIDA, 'DD/MM/YYYY')||' às '||T.HORAMIN||' hrs
                            <p style="color:red;">Para cancelar ou alterar a programação, entre em contato com o Departamento de TI<br/>
                            <p style="color:darkblue;"> Este é um e-mail automático - Não responda </p>
                            <p style="color:gray;"> TI - ERP | Sistemas<p>
                            <p style="font-size: 12px; color:lightgray;">Desenvolvido por Giuliano | Cipolla - TI | Param.: Ricardo Santana</p>
                          </HTML>', 'N');
  /*<p style="font-size: 12px; color:lightgray;">Desenvolvido por Giuliano | Cipolla - TI</p>*/
        COMMIT; 
     END ;  
   END LOOP;
 END;
 
BEGIN
   CONSINCO.NAGP_EMAILAUTO_LOTECOMPRAS;
  END;
  
SELECT * FROM CONSINCO.NAGT_EMAILCOMPRADORES X 
       
