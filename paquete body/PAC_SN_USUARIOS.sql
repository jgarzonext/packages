--------------------------------------------------------
--  DDL for Package Body PAC_SN_USUARIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SN_USUARIOS" 
/*
 * Autor:
 *   JBP8301 ('Sa Nostra' Assegurances)
 * Data:
 *   15 de maig 2007
 * Descripció:
 *   Funcions i procediments relacionats amb la gestió d'usuaris de Sa Nostra.
 */
AS
--*----
-- Procés: Procediment que llegeix el fitxer d'usuaris de sa nostra volcat
--         diàriament. Només es processen els usuaris d'oficines. Els usuaris
--         que no existeixen al fitxer es donen de baixa a la taula usuarios.
--         Els usuaris que es llegeixen del fitxer però no hi són a la taula
--         es donen d'alta i els que estaven donats de baixa s'actualitzen.
--*----
   PROCEDURE p_ges_usuarios_batch (
      pcempres   IN       NUMBER,                  /* Codi d'empresa */
      pmaxbajas  IN       NUMBER,
                           /* Màxim de baixes que es poden processar */
      pnomfich   IN       VARCHAR2,
                                                    /* Nom de fitxer */
      pretcode   OUT      NUMBER,            /* Retorna codi d'error */
      psproces   IN OUT   NUMBER
                                /* Si és NULL s'inicia un nou procés */
   )
   IS
      rutafich    VARCHAR2 (255);           /* Directori del fitxer */
      nomfich     VARCHAR2 (255);                 /* Nom del fitxer */
      lineafich   NVARCHAR2 (220);     /* Linia temporal del fitxer */
      fichero     UTL_FILE.FILE_TYPE;       /* Referencia al fitxer */
      v_cusuari   VARCHAR2 (7);
                      /* Variables temporals per a llegir el fitxer */
      v_cdelega   NUMBER;
      v_cagente   NUMBER;
      v_tusunom   VARCHAR2 (110);

      usu_exist   NUMBER;
      usu_baja    NUMBER;
      v_error     NUMBER;
      num_err     NUMBER             := 0;
      nbajas      NUMBER;
      numlinea    NUMBER;
      nproces     NUMBER;
      v_ctipage   NUMBER;

      FUNCTION validar_linea (pcadena IN VARCHAR2)
            /* Comprova el format de la linia recuperada del fitxer */
         RETURN BOOLEAN
      IS
         cadena   VARCHAR2 (220);
      BEGIN
         cadena := TRIM (pcadena);

         IF     LENGTH (cadena) IS NOT NULL
            AND LENGTH (TRIM (TRANSLATE (SUBSTR (cadena, 145, 4),
                                         ' 0123456789',
                                         ' '
                                        )
                             )
                       ) IS NULL
            AND LENGTH (TRIM (SUBSTR (cadena, 1, 8))) IS NOT NULL
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END validar_linea;
   BEGIN
      IF psproces IS NULL  /* Si no reb com a paràmetre crea un nou procés */
      THEN
         v_error :=
            F_Procesini (F_USER,
                         pcempres,
                         'GES_USUARIOS',
                         'Gestión de usuarios',
                         nproces
                        );
      ELSE
         nproces := psproces;
      END IF;

      rutafich := F_Parinstalacion_T ('PATH_DEVOL');
      nomfich := pnomfich;

      DELETE FROM TMP_REDCOMERCIAL;         /* Esborra les dades temporals */

      IF NOT UTL_FILE.IS_OPEN(fichero)
      THEN
         fichero := UTL_FILE.FOPEN (rutafich, nomfich, 'r');
      END IF;

      LOOP                               /* Llegeix el fitxer usuarios.dat */
         BEGIN
            UTL_FILE.GET_LINE (fichero, lineafich);

            IF validar_linea (lineafich)          /* Validació de la linia */
            THEN
               v_cusuari := UPPER (TRIM (SUBSTR (lineafich, 1, 8)));
               v_cdelega := TO_NUMBER (TRIM (SUBSTR (lineafich, 145, 4)));
               v_tusunom :=
                  UPPER (   TRIM (SUBSTR (lineafich, 41, 44))
                         || ' '
                         || TRIM (SUBSTR (lineafich, 85, 35))
                         || ' '
                         || TRIM (SUBSTR (lineafich, 120, 22))
                        );

               IF Pac_Sn_Agentes.f_es_oficina (v_cdelega) = 1
                                                        /* Usuari d'oficina */
               THEN
                  INSERT INTO TMP_REDCOMERCIAL /* Insereix a taula temporal */
                              (cusuari
                              )
                       VALUES (v_cusuari
                              );

                  SELECT COUNT (1)    /* Comprova si l'usuari està de baixa */
                    INTO usu_baja
                    FROM USUARIOS
                   WHERE UPPER (cusuari) = v_cusuari AND fbaja IS NOT NULL;

                  SELECT COUNT (1)         /* Comprova si l'usuari existeix */
                    INTO usu_exist
                    FROM USUARIOS
                   WHERE UPPER (cusuari) = v_cusuari;

                  SELECT ctipage                          /* Consulta tipus d'agent */
                    INTO v_ctipage
                    FROM redcomercial
                   WHERE cagente = v_cdelega
                     AND cempres = NVL (pcempres, 1)
                     AND fmovfin IS NULL;

                  IF usu_baja = 1                            /* Si existeix */
                     AND v_ctipage = 5                        /* Només d'oficines */
                  THEN
                     /* Actualitzar usuari: anul·la data de baixa */
                     UPDATE USUARIOS
                        SET fbaja = NULL
                      WHERE UPPER (cusuari) = v_cusuari;

                     v_error :=
                        F_Proceslin (nproces,
                                     'Alta usuario: ' || v_cusuari,
                                     1,
                                     numlinea,
                                     4
                                    );
                  ELSIF usu_exist <> 1
                  THEN
                     /* Alta usuari */
                     INSERT INTO USUARIOS
                                 (cusuari, cidioma, cempres, tusunom,
                                  cdelega, ctipusu, fbaja, tpcpath
                                 )
                          VALUES (v_cusuari, 1, pcempres, v_tusunom,
                                  v_cdelega, 1, NULL, 'C:\'
                                 );
                     v_error :=
                        F_Proceslin (nproces,
                                        'Alta usuario: ' || v_cusuari,
                                        1,
                                        numlinea,
                                        4
                                       );
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
         END;
      END LOOP;                             /* Acaba la lectura del fitxer */

      SELECT COUNT (1)     /* Nombre d'usuaris que s'han de donar de baixa */
        INTO nbajas
        FROM USUARIOS
       WHERE fbaja IS NULL
         AND Pac_Sn_Agentes.f_es_oficina (cdelega) = 1
         AND UPPER (cusuari) NOT IN (SELECT cusuari
                                       FROM TMP_REDCOMERCIAL);

      IF nbajas > 0                           /* Comprova que el nombre de */
      THEN                                    /* baixes estigui entre zero */
         IF nbajas < NVL(pmaxbajas,0)                        /* i el màxim */
         THEN
            FOR aux IN
               (SELECT cusuari
                  FROM USUARIOS
                 WHERE fbaja IS NULL
                   AND Pac_Sn_Agentes.f_es_oficina (cdelega) = 1
                   AND UPPER (cusuari) NOT IN (SELECT cusuari
                                                 FROM TMP_REDCOMERCIAL))
            LOOP
               /* Baixa usuari */
               UPDATE USUARIOS u
                  SET u.fbaja = SYSDATE
                WHERE UPPER (u.cusuari) = UPPER (aux.cusuari);

               v_error :=
                  F_Proceslin (nproces,
                                  'Baja usuario: ' || UPPER(aux.cusuari),
                                  1,
                                  numlinea,
                                  4
                              );
            END LOOP;
         ELSE
            num_err := num_err + 1;
            v_error :=
               F_Proceslin (nproces,
                            'Se ha superado el número máximo de bajas.',
                            1,
                            numlinea,
                            1
                           );
            NULL;
         END IF;
      ELSE
         /* No hi ha baixes */
         NULL;
      END IF;
      IF UTL_FILE.IS_OPEN (fichero)
      THEN
         UTL_FILE.FCLOSE (fichero);
      END IF;

      P_Generar_Copia_Fichero(rutafich,
                              nomfich,
                              rutafich,
                              RTRIM (nomfich, '.dat')
                           || TO_CHAR(SYSDATE,'_yyyymmdd')
                           || '.dat',
                              nproces,
                              'S');
      COMMIT;
      v_error := F_Proceslin (nproces, 'Proceso finalizado.', 1, numlinea,4);
      pretcode := 0;
      IF psproces IS NULL                                 /* fi del procés */
      THEN
         v_error := F_Procesfin (nproces, num_err);
      END IF;
      psproces := nproces;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         num_err := num_err + 1;

          v_error :=
             F_Proceslin (nproces,
                          SUBSTR (SQLERRM(SQLCODE),1,120),
                          1,
                          numlinea,
                          1
                         );
         pretcode := SQLCODE;

         IF UTL_FILE.IS_OPEN (fichero)
         THEN
            UTL_FILE.FCLOSE (fichero);
         END IF;

         IF psproces IS NULL           /* fi del procés si hi ha problemes */
         THEN
            v_error := F_Procesfin (nproces, num_err);
         END IF;

         psproces := nproces;

   END p_ges_usuarios_batch;
END Pac_Sn_Usuarios;

/

  GRANT EXECUTE ON "AXIS"."PAC_SN_USUARIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SN_USUARIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SN_USUARIOS" TO "PROGRAMADORESCSI";
