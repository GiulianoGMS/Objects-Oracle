CREATE OR REPLACE PROCEDURE SP_CARGA_PRECO_NAGUMO_V2(PNNROJOB     IN   NUMBER,
                                                     PNMODEMPRESA IN   NUMBER   ) IS
  VSSOFT           VARCHAR2(50);
  VSHORA           VARCHAR2(2);
  VSTIPOCARGA      VARCHAR2(10);
  OBJ_PARAM_SMTP   C5_TP_PARAM_SMTP;
  VSSQL            VARCHAR2(2000);
BEGIN
  SELECT TO_CHAR(SYSDATE, 'HH24')
  INTO   VSHORA
  FROM   DUAL;
  IF VSHORA IN ('01', '09', '13')  THEN
     VSSQL :=
     'insert into nag_job(nrojob, dtamovimento,    erro)
                 values ('||PNNROJOB||',    trunc(sysdate), ''Inicio: ' || TO_CHAR(SYSDATE,'dd-mm-yyyy HH24:mi:ss')||''')';
     EXECUTE IMMEDIATE VSSQL;
  END IF;
  IF VSHORA = '01' THEN
     VSTIPOCARGA := 'Total';
  ELSIF VSHORA IN ('09', '13')  THEN
        VSTIPOCARGA := 'Parcial';
  END IF;
  IF VSHORA IN ('01', '09', '13')  THEN
     FOR I IN (SELECT * FROM MAX_EMPRESA A
               WHERE A.STATUS = 'A'
               AND  MOD(A.NROEMPRESA,5) = PNMODEMPRESA
               AND  NROEMPRESA < 500
               ORDER BY 1)
     LOOP
       OBJ_PARAM_SMTP := C5_TP_PARAM_SMTP(1);
       IF VSHORA IN ('01', '09', '13')  THEN
          IF VSHORA <> '03' THEN
             --GERANDO PROMOCAO
             PKG_MAD_ADMPRECO.SP_GERAPROMOCAO(I.NROSEGMENTOPRINC, I.NROEMPRESA, TRUNC(SYSDATE), 'AUTOMATICO');
             --VALIDANDO PRECOS
             PKG_MAD_ADMPRECO.SP_VALIDAPRECO(I.NROSEGMENTOPRINC, I.NROEMPRESA,'AUTOMATICO', 'T');
          END IF;
          BEGIN
            SPMRL_CARGAPDVCORAL(I.NROEMPRESA, TRUNC(SYSDATE), VSTIPOCARGA, NULL);
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN

              --- COMENTADO POR CIPOLLA EM 06/03/2023, CASO APRESENTE ERRO SERÁ ENVIADO E-MAIL. SOLICITAÇÃO LUCIMAR - TICKET C5 16317714
/*              VSSQL :=
              'insert into nag_job(nrojob, dtamovimento,  nroempresa,  erro)
                          values ('||PNNROJOB||',    trunc(sysdate), i.nroempresa, ''Erro ao gerar a carga de PDV da empresa'')';
              EXECUTE IMMEDIATE VSSQL;*/

              SP_ENVIA_EMAIL(OBJ_PARAM      => OBJ_PARAM_SMTP,
                             PSDESTINATARIO => 'giuliano.gomes@nagumo.com.br',
                             PSASSUNTO      => 'Erro ao gerar a carga de PDV da empresa ' || TO_CHAR(I.NROEMPRESA),
                             PSMENSAGEM     => 'Erro ao gerar a carga de PDV da empresa ' || TO_CHAR(I.NROEMPRESA)
                                               ||'ERRO: '||SQLERRM,
                             PSINDUSAHTML   => 'N');
          END;
          -- ADICIONADO POR GIULIANO - TRATAMENTO PARCIAL/TOTAL BALANCA
          IF VSTIPOCARGA = 'Total' THEN
          BEGIN
            FOR BAL IN (SELECT NROEMPRESA, SOFTPDV
                        FROM   MRL_EMPSOFTPDV
                        WHERE  TIPOSOFT   =  'B'
                        AND    SOFTPDV = 'TOLEDOPRIX4' -- Adicionado filtro por Giuliano | Dif ESP_TOLEDO_PARCIAL nao entra no loop
                        AND    NROEMPRESA =  I.NROEMPRESA)
            LOOP
              INSERT  INTO MRL_LOGEXPORTACAO(NROEMPRESA,       SOFTPDV,         DTAHOREXPORTACAO,     USUEXPORTACAO,
                                             TIPOLOG,          PARAM1,          PARAM2,               PARAM3,
                                             PARAM4,           PARAM5,          DTAMOVIMENTO )
                                   VALUES   (BAL.NROEMPRESA,   BAL.SOFTPDV,     SYSDATE,              'JOB209',
                                             'T',              NULL,            NULL,                 TRUNC(SYSDATE),
                                             NULL,             NULL,            NULL) ;
              COMMIT;
            END LOOP;
            EXCEPTION

            WHEN OTHERS THEN

              SP_ENVIA_EMAIL(OBJ_PARAM      => OBJ_PARAM_SMTP,
                             PSDESTINATARIO => 'giuliano.gomes@nagumo.com.br',
                             PSASSUNTO      => 'Erro ao gerar a carga TOTAL da balança da empresa: ' || TO_CHAR(I.NROEMPRESA),
                             PSMENSAGEM     => 'Erro ao gerar a carga TOTAL da balança da empresa: ' || TO_CHAR(I.NROEMPRESA)
                                               ||'ERRO: '||SQLERRM,
                             PSINDUSAHTML   => 'N');
            END;
          ELSE
            BEGIN
              ESPP_CPT_GERACARGATOLETO(I.NROEMPRESA,SYSDATE, 'N');
               COMMIT;                
                
              EXCEPTION

            WHEN OTHERS THEN

              SP_ENVIA_EMAIL(OBJ_PARAM      => OBJ_PARAM_SMTP,
                             PSDESTINATARIO => 'giuliano.gomes@nagumo.com.br',
                             PSASSUNTO      => 'Erro ao gerar a carga PARCIAL da balança da empresa: ' || TO_CHAR(I.NROEMPRESA),
                             PSMENSAGEM     => 'Erro ao gerar a carga PARCIAL da balança da empresa: ' || TO_CHAR(I.NROEMPRESA)
                                               ||'ERRO: '||SQLERRM,
                             PSINDUSAHTML   => 'N');
             END;
           --
           END IF;

       END IF;
     END LOOP;
  END IF;
  IF VSHORA IN ('01', '09', '13')  THEN
     VSSQL :=
     'insert into nag_job(nrojob, dtamovimento,    erro)
                 values ('||PNNROJOB||',    trunc(sysdate), ''Final: ' || TO_CHAR(SYSDATE,'dd-mm-yyyy HH24:mi:ss')||''')';
  END IF;
  COMMIT;
END SP_CARGA_PRECO_NAGUMO_V2;
