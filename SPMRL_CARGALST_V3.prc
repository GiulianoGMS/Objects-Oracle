CREATE OR REPLACE PROCEDURE CONSINCO.SPMRL_CARGALST_V3 (psNROEMPRESA          IN   VARCHAR2,
                                                        psTIPOLOG             IN   MRL_LOGEXPORTACAO.PARAM1%TYPE,
                                                        psBALANCA             IN   MRL_LOGEXPORTACAO.PARAM2%TYPE DEFAULT 'S')
   IS
      vsTIPOCARGA  VARCHAR2(1);
      vnRETORNO    NUMBER;
      vnNROSEG     NUMBER;
   BEGIN
     FOR EMP IN (SELECT * FROM CONSINCO.MAX_EMPRESA A
                 WHERE A.STATUS = 'A'
                 AND   A.NROEMPRESA < 500
                 AND   A.NROEMPRESA IN (SELECT * FROM TABLE(CONSINCO.FC5_STRTOKENIZE(psNROEMPRESA, ',')))
                 ORDER BY 1 )
     LOOP
       IF psTIPOLOG != 'Não Gera' OR psBALANCA != 'Não' THEN

         SELECT A.NROSEGMENTOPRINC
         INTO   vnNROSEG
         FROM   MAX_EMPRESA A
         WHERE  NROEMPRESA = EMP.NROEMPRESA;

         CONSINCO.PKG_MAD_ADMPRECO.SP_GERAPROMOCAO(vnNROSEG, EMP.NROEMPRESA, TRUNC(SYSDATE), 'AUTOMATICO');
         CONSINCO.PKG_MAD_ADMPRECO.SP_VALIDAPRECO(vnNROSEG, EMP.NROEMPRESA,'AUTOMATICO', 'T');
         COMMIT;

         IF psTIPOLOG = 'Parcial' THEN
            vsTIPOCARGA := 'P';   -- PARCIAL
         ELSIF
            psTIPOLOG = 'Total'   THEN
            vsTIPOCARGA := 'T';   -- TOTAL
         END IF;

         DELETE FROM MRL_CARGAPDV_PRODUTO P
         WHERE  P.NROEMPRESA = EMP.NROEMPRESA; 

         VNRETORNO := CONSINCO.PKG_PDVCORAL.FEXP_PDVCORAL(EMP.NROEMPRESA, TRUNC(SYSDATE), vsTIPOCARGA, TRUNC(SYSDATE));

         -- ALTERACAO PARA RESPEITAR TIPO DA CARGA NA BALANCA - ALTERADO POR GIULIANO EM 01/12/23

         IF psBALANCA = 'Parcial' THEN
          -- Gera Parcial
         BEGIN
           CONSINCO.ESPP_CPT_GERACARGATOLETO(emp.NROEMPRESA,TRUNC(SYSDATE), 'N');
               COMMIT;

         END;
           --
         ELSIF psBALANCA = 'Total' THEN
         
           FOR BAL IN (SELECT  B.NROEMPRESA, B.SOFTPDV
                            FROM   CONSINCO.MRL_EMPSOFTPDV B
                            WHERE  B.TIPOSOFT   =  'B'
                            AND    B.NROEMPRESA =   EMP.NROEMPRESA)
                LOOP
                  INSERT  INTO CONSINCO.MRL_LOGEXPORTACAO(NROEMPRESA,       SOFTPDV,         DTAHOREXPORTACAO,     USUEXPORTACAO,
                                                 TIPOLOG,          PARAM1,          PARAM2,               PARAM3,
                                                 PARAM4,           PARAM5,          DTAMOVIMENTO )
                                       VALUES    (BAL.NROEMPRESA,   BAL.SOFTPDV,     SYSDATE,              'JOB209',
                                                  'T',              NULL,            NULL,                 TRUNC(SYSDATE),
                                                   NULL,             NULL,            NULL) ;
                END LOOP;
               COMMIT;

          END IF;
           
       END IF;
    END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR (-20200, SQLERRM );

END SPMRL_CARGALST_V3;
