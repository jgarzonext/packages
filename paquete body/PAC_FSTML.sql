--------------------------------------------------------
--  DDL for Package Body PAC_FSTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FSTML" 
IS
   k_carxlin   fstml_fichero.carxlin%TYPE;
   k_linxpag   fstml_fichero.linxpag%TYPE;
   k_abrev     fstml_fichero.tabrev%TYPE;
   k_poscab    fstml_fichero.poscab%TYPE;
   coderror    NUMBER                       := 0;

   FUNCTION f_escribir_registro (
      psec       NUMBER,
      nlinea     NUMBER,
      pfichero   NUMBER,
      tipo       NUMBER,
      registro   VARCHAR2
   )
      RETURN NUMBER
   AS
   BEGIN
      INSERT INTO fstml_datos
                  (sdatos, nlinea, cfichero, tipo,
                   registro
                  )
           VALUES (psec, nlinea, pfichero, tipo,
                   RPAD (registro, k_carxlin, ' ')
                  );

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_escribir_registro;

   FUNCTION f_cabecera (pfichero NUMBER, psec NUMBER, linea NUMBER)
      RETURN NUMBER
   AS
      tpagina      VARCHAR2 (15);
      aux          NUMBER;
      vregistro    fstml_datos.registro%TYPE;
      nlinea       NUMBER;
      npagina      NUMBER;
      ctrl_2_lin   NUMBER;
   BEGIN
      nlinea := linea;

      SELECT COUNT (1) + 1
        INTO npagina
        FROM fstml_datos
       WHERE tipo = 1 AND sdatos = psec;

      tpagina := 'PAGINA : ' || npagina;
      vregistro := '1' || RPAD ('SA NOSTRA', k_carxlin - 20, ' ') || tpagina;
      ctrl_2_lin := 0;

      FOR reg IN (SELECT   texto
                      FROM fstml_cabecera
                     WHERE cfichero = pfichero
                  ORDER BY norden)
      LOOP
         IF ctrl_2_lin = 1
         THEN
            vregistro :=
                  ' '
               || RPAD ('INFORME ' || k_abrev, k_carxlin - 20, ' ')
               || 'FECHA  : '
               || TO_CHAR (f_sysdate, 'DD/MM/YYYY');
         END IF;

         vregistro :=
               SUBSTR (vregistro, 1, k_poscab - 1)
            || reg.texto
            || SUBSTR (vregistro, k_poscab + LENGTH (reg.texto));
         nlinea := nlinea + 1;

         IF ctrl_2_lin = 0
         THEN
            coderror :=
                   f_escribir_registro (psec, nlinea, pfichero, 1, vregistro);
         ELSE
            coderror :=
                   f_escribir_registro (psec, nlinea, pfichero, 2, vregistro);
         END IF;

         ctrl_2_lin := ctrl_2_lin + 1;
      END LOOP;

      IF ctrl_2_lin = 1
      THEN
         vregistro :=
               ' '
            || RPAD ('INFORME ' || k_abrev, k_carxlin - 20, ' ')
            || 'FECHA  : '
            || TO_CHAR (f_sysdate, 'DD/MM/YYYY');
         nlinea := nlinea + 1;
         coderror :=
                    f_escribir_registro (psec, nlinea, pfichero, 2, vregistro);
      END IF;

      RETURN nlinea;
   END f_cabecera;

   FUNCTION f_ruptura (
      pfichero   NUMBER,
      psec       NUMBER,
      linea      NUMBER,
      lin_temp   NUMBER
   )
      RETURN NUMBER
   AS
      nlinea      NUMBER;
      vregistro   VARCHAR2 (250);
   BEGIN
      nlinea := linea;

      FOR reg IN (SELECT d.etiqueta, t.valor, d.longitud, d.numerico
                    FROM fstml_temp t, fstml_detalle d
                   WHERE d.cfichero = pfichero
                     AND t.ccampo = d.ccampo
                     AND d.ruptura = 1
                     AND t.nlinea = lin_temp)
      LOOP
         nlinea := nlinea + 1;

         IF reg.numerico = 1
         THEN
            reg.valor := LPAD (reg.valor, reg.longitud, '0');
         END IF;

         vregistro := LPAD (reg.etiqueta || ': ', 75, ' ') || reg.valor;
         coderror :=
                    f_escribir_registro (psec, nlinea, pfichero, 2, vregistro);
      END LOOP;

      RETURN nlinea;
   END f_ruptura;

   FUNCTION f_detalle (pfichero NUMBER, psec NUMBER, linea NUMBER)
      RETURN NUMBER
   AS
      detalle1   VARCHAR2 (2500) := ' ';
      detalle2   VARCHAR2 (2500) := ' ';
      nlinea     NUMBER;
   BEGIN
      nlinea := linea;

      FOR reg IN (SELECT   etiqueta, longitud
                      FROM fstml_detalle
                     WHERE cfichero = pfichero AND visible = 1
                  ORDER BY pos_out)
      LOOP
         detalle1 := detalle1 || RPAD (reg.etiqueta, reg.longitud, ' ')
                     || ' ';
         detalle2 := detalle2 || RPAD ('-', reg.longitud, '-') || ' ';
      END LOOP;

      IF LENGTH (detalle1) > 1
      THEN
         detalle1 := RPAD (detalle1, k_carxlin, ' ');
         detalle2 := RPAD (detalle2, k_carxlin, '-');
         nlinea := nlinea + 1;
         coderror :=
                    f_escribir_registro (psec, nlinea, pfichero, 2, detalle1);
         nlinea := nlinea + 1;
         coderror :=
                    f_escribir_registro (psec, nlinea, pfichero, 2, detalle2);
      END IF;

      RETURN nlinea;
   END f_detalle;

   FUNCTION f_ctrl_ruptura (pfichero NUMBER, lin_temp NUMBER, filtro OUT NUMBER)
      RETURN NUMBER
   AS
      aux       NUMBER;
      val_ant   VARCHAR2 (250);
      val_act   VARCHAR2 (250);
   BEGIN
      aux := 0;

      FOR reg IN (SELECT ccampo
                    FROM fstml_detalle
                   WHERE pfichero = cfichero AND ruptura = 1)
      LOOP
         filtro := 1;

         BEGIN
            SELECT valor
              INTO val_ant
              FROM fstml_temp
             WHERE fstml_temp.ccampo = reg.ccampo
               AND nlinea = lin_temp - 1
               AND cfichero = pfichero;
         EXCEPTION
            WHEN OTHERS
            THEN
               val_ant := NULL;
         END;

         BEGIN
            SELECT valor
              INTO val_act
              FROM fstml_temp
             WHERE fstml_temp.ccampo = reg.ccampo
               AND nlinea = lin_temp
               AND cfichero = pfichero;
         EXCEPTION
            WHEN OTHERS
            THEN
               val_act := NULL;
         END;

         IF val_act != val_ant OR val_ant IS NULL
         THEN
            aux := 1;
            EXIT;
         END IF;
      END LOOP;

      RETURN aux;
   END f_ctrl_ruptura;

   FUNCTION f_ctrl_linea (
      pfichero         NUMBER,
      psec             NUMBER,
      lin_temp         NUMBER,
      pruptura   OUT   NUMBER
   )
      RETURN NUMBER
   AS
      nlinea     NUMBER (5);
      filtro     NUMBER (1);
      ctrl_lin   NUMBER (5);
   BEGIN
      SELECT NVL (MAX (nlinea), 0)                                 -- COUNT(1)
        INTO nlinea
        FROM fstml_datos
       WHERE sdatos = psec;

      SELECT COUNT (1)
        INTO ctrl_lin
        FROM fstml_datos
       WHERE sdatos = psec AND nlinea >= (SELECT NVL (MAX (nlinea), 0)
                                            FROM fstml_datos
                                           WHERE sdatos = psec AND tipo = 1);

      pruptura := f_ctrl_ruptura (pfichero, lin_temp, filtro);

      IF MOD (ctrl_lin, k_linxpag) = 0 OR nlinea = 0 OR pruptura = 1
      THEN
         pruptura := 1;
         nlinea := f_cabecera (pfichero, psec, nlinea);

         IF filtro = 1
         THEN
            nlinea := f_ruptura (pfichero, psec, nlinea, lin_temp);
         END IF;

         nlinea := nlinea + 1;
         coderror :=
            f_escribir_registro (psec,
                                 nlinea,
                                 pfichero,
                                 2,
                                 RPAD (' -', k_carxlin, '-')
                                );
         nlinea := f_detalle (pfichero, psec, nlinea);
      END IF;

      RETURN nlinea;
   END f_ctrl_linea;

   FUNCTION f_secuencia (valor NUMBER)
      RETURN NUMBER
   AS
      aux   NUMBER;
   BEGIN
      IF valor IS NOT NULL
      THEN
         aux := valor;
      ELSE
         SELECT s_fstml_datos.NEXTVAL
           INTO aux
           FROM DUAL;
      END IF;

      RETURN aux;
   END f_secuencia;

   FUNCTION f_montar_fichero (
      pfichero              NUMBER,
      pdatos                VARCHAR2,
      psecuencia   IN OUT   NUMBER,
      plinea		 IN OUT   NUMBER
   )
      RETURN NUMBER
   AS
      vsep        fstml_fichero.separador%TYPE;
      cont        NUMBER;
      vdatos      VARCHAR2 (2500);
      nlinea      NUMBER (5);
      masc        VARCHAR2 (15);
      vvalor      fstml_temp.valor%TYPE;
      vregistro   fstml_datos.registro%TYPE;
      venabled    fstml_detalle.visible%TYPE;
      vruptura    fstml_detalle.ruptura%TYPE;
      vnumerico   fstml_detalle.numerico%TYPE;
      vdiv        fstml_detalle.dividir%TYPE;
   BEGIN
      psecuencia := f_secuencia (psecuencia);

      SELECT separador, carxlin + 1, linxpag, tabrev, poscab
        INTO vsep, k_carxlin, k_linxpag, k_abrev, k_poscab
        FROM fstml_fichero
       WHERE cfichero = pfichero;

      cont := 1;

		IF NVL(plinea,0) = 0 THEN
		  plinea := 1;
		ELSE
		  plinea := plinea + 1;
		END IF;

      vdatos := pdatos;

      IF SUBSTR (vdatos, LENGTH (vdatos)) = vsep
      THEN
         vdatos := SUBSTR (vdatos, 1, LENGTH (vdatos) - 1);
      END IF;

      LOOP
         vvalor := SUBSTR (vdatos, 1, INSTR (vdatos, vsep) - 1);
         vdatos := SUBSTR (vdatos, INSTR (vdatos, vsep) + 1);

         IF vvalor IS NULL
         THEN
            vvalor := vdatos;
         END IF;

         SELECT NVL (visible, 0), NVL (ruptura, 0), numerico, NVL (dividir, 1)
           INTO venabled, vruptura, vnumerico, vdiv
           FROM fstml_detalle
          WHERE cfichero = pfichero AND pos_in = cont;

         IF (venabled = 1) OR (vruptura = 1)
         THEN
            IF vnumerico = 1
            THEN
               BEGIN
                  vvalor := TO_NUMBER (NVL (vvalor, 0));

                  IF vdiv > 1
                  THEN
                     vvalor := TO_NUMBER (vvalor) / vdiv;

                     IF SUBSTR (vvalor, 1, 1) = ','
                     THEN
                        vvalor := '0' || vvalor;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     vvalor := 0;
               END;
            END IF;

            INSERT INTO fstml_temp
                        (ccampo, nlinea, valor, cfichero
                        )
                 VALUES (cont, plinea, vvalor, pfichero
                        );
         END IF;

         cont := cont + 1;

         IF vvalor = vdatos
         THEN
            EXIT;
         END IF;
      END LOOP;

      nlinea := f_ctrl_linea (pfichero, psecuencia, plinea, vruptura);
      vregistro := ' ';

      FOR reg IN (SELECT   t.ccampo, t.valor, d.align, d.longitud, d.visible
                      FROM fstml_temp t, fstml_detalle d
                     WHERE d.cfichero = pfichero
                       AND t.ccampo = d.ccampo
                       AND t.nlinea = plinea
                  ORDER BY d.pos_out)
      LOOP
         IF reg.visible = 1
         THEN
            IF reg.align = 'D'
            THEN
               vregistro :=
                       vregistro || LPAD (reg.valor, reg.longitud, ' ')
                       || ' ';
            ELSE
               vregistro :=
                       vregistro || RPAD (reg.valor, reg.longitud, ' ')
                       || ' ';
            END IF;
         END IF;
      END LOOP;

      BEGIN
         nlinea := nlinea + 1;
         coderror :=
             f_escribir_registro (psecuencia, nlinea, pfichero, 3, vregistro);
      EXCEPTION
         WHEN OTHERS
         THEN
            coderror := SQLCODE;
      END;

      RETURN coderror;
   END f_montar_fichero;

   FUNCTION f_escribir_fichero (
      pfichero              NUMBER,
      psecuencia            NUMBER,
      nomfich      IN OUT   VARCHAR2
   )
      RETURN NUMBER
   AS
      vfichero   UTL_FILE.file_type;
      vhost      VARCHAR2 (100);
      vnomfich   VARCHAR2 (50);
   BEGIN
      vhost := f_parinstalacion_t ('PATH_FASES');

      IF nomfich IS NULL
      THEN
         SELECT fich_out
           INTO  nomfich
           FROM fstml_fichero
          WHERE cfichero = pfichero;
      END IF;

      IF UTL_FILE.is_open (vfichero)
      THEN
         UTL_FILE.fclose (vfichero);
      END IF;

      vfichero := UTL_FILE.fopen (vhost, nomfich, 'W', 3200);

      FOR reg IN (SELECT   registro
                      FROM fstml_datos
                     WHERE cfichero = pfichero AND sdatos = psecuencia
                  ORDER BY nlinea)
      LOOP
         UTL_FILE.put_line (vfichero, reg.registro);
      END LOOP;

      UTL_FILE.fclose (vfichero);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_escribir_fichero;
END pac_fstml;

/

  GRANT EXECUTE ON "AXIS"."PAC_FSTML" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FSTML" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FSTML" TO "PROGRAMADORESCSI";
