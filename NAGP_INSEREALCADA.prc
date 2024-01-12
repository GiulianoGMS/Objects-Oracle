CREATE OR REPLACE PROCEDURE NAGP_INSEREALCADA (psGrupo IN VARCHAR2) IS

      i INTEGER := 0;

      BEGIN
        FOR usu IN (SELECT C.CODUSUARIO, C.SEQUSUARIO
                      FROM CONSINCO.GE_USUARIO A LEFT JOIN CONSINCO.GE_MEMBRO B ON A.SEQUSUARIO = B.GRUPO
                                                 LEFT JOIN (SELECT *
                                                 FROM CONSINCO.GE_USUARIO WHERE TIPOUSUARIO = 'U') C ON B.USUARIO = C.SEQUSUARIO

                      WHERE A.TIPOUSUARIO = 'G'
                      AND UPPER(A.CODUSUARIO) = UPPER(psGrupo))

       LOOP
         BEGIN
           i := i+1;

           INSERT INTO FI_USUALCADA (SELECT USU.SEQUSUARIO,
                                            F.CODESPECIE,
                                            F.NROEMPRESAMAE,
                                            usu.CODUSUARIO,
                                            9999999999999.00,
                                            SYSDATE,
                                           'VIEW_SD',
                                            9999999999999.00 FROM FI_ESPECIE F
                                                    WHERE OBRIGDIREITO = 'O'
                                                      AND CODESPECIE NOT IN (SELECT CODESPECIE
                                                                               FROM FI_USUALCADA
                                                                              WHERE SEQUSUARIO = usu.SEQUSUARIO
                                                                                AND NROEMPRESAMAE = F.NROEMPRESAMAE));
            IF i = 10 THEN COMMIT;
            i := 0;
      END IF;

      END;
     END LOOP;
    COMMIT;

   END;
