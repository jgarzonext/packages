CREATE OR REPLACE PACKAGE BODY pac_agensegu
AS
   /******************************************************************************
      NOMBRE:       pac_agensegu
      PROPÓSITO:  Gestión de los apuntes de la agenda de una póliza

      REVISIONES:
      Ver        Fecha        Autor           Descripción
      ---------  ----------  --------     ------------------------------------
      1.0        05/03/2009   JSP         1. Creación del package.
      2.0        09/07/2009   DCT         2. Modificacion funciones. Añadir nuevo parametro pncertif
      3.0        25/09/2009   NMM         3. 11177: CRE - Agenda de póliza.Canvi long. vparam.
      4.0        10/11/2009   JTS         4. 11177: CRE - Agenda de póliza.Canvi long. vparam.
      5.0        28/10/2011   APD         5. 0018946: LCOL_P001 - PER - Visibilidad en personas
      6.0        22/05/2020   ECP         6. IAXIS-13888. Gestión Agenda
   ******************************************************************************/

   /*************************************************************************
   Función F_GET_ConsultaApuntes
   Obtiene la información sobre apuntes de la agenda dependiendo de los parámetros de entrada
   param in Pctipreg : concepto de apunte
   param in Pnpoliza : nº de póliza relacionada al apunte
   param in pncertif : nº de certificado de la póliza
   param in pnlinea : nº de apunte relacionado a la póliza
   param in pcidioma : idioma en que recuperaremos los textos
   param in Pcestado: estado del apunte (0:Automático, 1:Manual)
   param in Pfapunte: fecha alta del apunte
   param in Pcusuari: usuario que realiza el alta del apunte
   param in Psseguro: id. del seguro relacionado al apunte
   param out Psquery: consulta a realizar construida en función de los parámetros
          return              : 0 si ha ido bien
                                numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_get_consultaapuntes (
      pctipreg   IN       NUMBER,
      pnpoliza   IN       NUMBER,
      pncertif   IN       NUMBER,
      pnlinea    IN       NUMBER,
      pcidioma   IN       NUMBER,
      pcestado   IN       NUMBER,
      pfapunte   IN       DATE,
      pcusuari   IN       VARCHAR2,
      psseguro   IN       NUMBER,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery   VARCHAR2 (2000) := '';
      vparam    VARCHAR2 (500)
         :=    'parámetros - ctipreg:'
            || pctipreg
            || ' ,npoliza:'
            || pnpoliza
            || ' ,ncertif:'
            || pncertif
            || ' ,nlinea:'
            || pnlinea
            || ' ,pcidioma:'
            || pcidioma
            || ' ,pcestado:'
            || pcestado
            || ' ,fapunte:'
            || pfapunte
            || ' , cusuari:'
            || pcusuari
            || ' , sseguro:'
            || psseguro;
   BEGIN
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      vsquery :=
            ' SELECT   s.npoliza,
                s.ncertif,
                a.nlinea,
                a.ctipreg,
                ff_desvalorfijo( 21 , '
         || pcidioma
         || ', a.ctipreg ) ttipreg,
                a.cmanual,
                ff_desvalorfijo(323 , '
         || pcidioma
         || ', a.cmanual ) tmanual,
                a.falta,
                a.ttitulo,
                a.ttextos,
                a.cusualt,
                a.cestado,
                ff_desvalorfijo(29 , '
         || pcidioma
         || ', a.cestado ) testado,
                a.ffinali,
                a.sseguro
       FROM AGENSEGU a, seguros S, agentes_agente_pol aa
       WHERE a.sseguro = s.sseguro
       and s.cagente = aa.cagente
       and s.cempres = aa.cempres';

      -- Bug 18946 - APD - 28/10/2011 - fin
      IF pctipreg IS NOT NULL
      THEN
         vsquery := vsquery || ' and a.ctipreg = ' || pctipreg;
      END IF;

      IF pnpoliza IS NOT NULL
      THEN
         vsquery := vsquery || ' and s.npoliza = ' || pnpoliza;
      END IF;

      IF pncertif IS NOT NULL
      THEN
         vsquery := vsquery || ' and s.ncertif = ' || pncertif;
      END IF;

      IF pnlinea IS NOT NULL
      THEN
         vsquery := vsquery || ' and a.nlinea = ' || pnlinea;
      END IF;

      IF pcestado IS NOT NULL
      THEN
         vsquery := vsquery || ' and a.cestado = ' || pcestado;
      END IF;

      IF pfapunte IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' and to_char(a.falta,''YYYYMMDD'') = '
            || TO_CHAR (pfapunte, 'YYYYMMDD');
      END IF;

      IF pcusuari IS NOT NULL
      THEN
         vsquery := vsquery || ' and a.cusualt = ''' || pcusuari || '''';
      END IF;

      IF psseguro IS NOT NULL
      THEN
         vsquery := vsquery || ' and a.sseguro = ' || psseguro;
      END IF;

      vsquery := vsquery || ' ORDER BY s.npoliza, s.ncertif, a.nlinea';
      psquery := vsquery;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_agensegu.f_get_consultaapuntes',
                      1,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9001718;                              --Error al cercar apunts
   END f_get_consultaapuntes;

    /*************************************************************************
   Función F_GET_DATOSApunte
   Recupera la información de un apunte de la agenda en concreto en función de los parámetros de entrada psseguro y pnlinea
   param in Psseguro: id. del seguro relacionado al apunte
   param in Pnlinea: nº de apunte relacionado a la póliza
   param in pcidioma : idioma en que recuperaremos los textos
   param out Psquery: consulta a realizar construida en función de los parámetros
          return              : 0 si ha ido bien
                                numero error si ha ido mal
    *************************************************************************/
   FUNCTION f_get_datosapunte (
      psseguro   IN       NUMBER,
      pnlinea    IN       NUMBER,
      pcidioma   IN       NUMBER,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery   VARCHAR2 (2000) := '';
      vidioma   NUMBER;
      vparam    VARCHAR2 (500)
         :=    'parámetros -  sseguro:'
            || psseguro
            || ' ,nlinea:'
            || pnlinea
            || ' ,pcidioma:'
            || pcidioma;
   BEGIN
      IF psseguro IS NULL
      THEN
         RETURN 9000916;                                  -- Segur obligatori
      END IF;

      IF pnlinea IS NULL
      THEN
         vsquery :=
               
               -- Bug 11177.NMM.25/09/2009.Afegim ncertif
               'SELECT npoliza,ncertif,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
          FROM seguros
          WHERE sseguro='
            || psseguro;
      ELSE
         -- Bug 11177.NMM.25/09/2009.Afegim ncertif
         vsquery :=
               'SELECT
          s.npoliza,
          s.ncertif,
          a.nlinea,
          a.ttitulo,
          a.ttextos,
          a.cestado,
          ff_desvalorfijo(29 , '
            || pcidioma
            || ', a.cestado ) testado,
           a.ctipreg, ff_desvalorfijo( 21 , '
            || pcidioma
            || ', a.ctipreg ) ttipreg,
           a.falta, a.cusualt, a.fmodifi, a.cusumod, a.ffinali, a.sseguro,
           a.cmanual, ff_desvalorfijo(323 , '
            || pcidioma
            || ', a.cmanual ) tmanual
          FROM agensegu a, seguros s
          WHERE a.sseguro = s.sseguro and a.sseguro='
            || psseguro
            || ' and a.nlinea='
            || pnlinea;
      END IF;

      psquery := vsquery;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_agensegu.f_get_datosapunte',
                      1,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9001719;                 --Error al cercar un apunt en concret
   END f_get_datosapunte;

    /*************************************************************************
   Función F_GET_ApuntesPendientes
   Valida si existen apuntes pendientes en la agenda para el usuario a día de hoy.
          return              : Numero de apuntes pendientes
    *************************************************************************/
   FUNCTION f_get_apuntespendientes
      RETURN NUMBER
   IS
      v_apuntespendientes   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_apuntespendientes
        FROM agensegu
       WHERE cusualt = f_user AND cestado = 0 AND falta <= f_sysdate;

      RETURN v_apuntespendientes;
   END f_get_apuntespendientes;

   /*************************************************************************
   Función F_SET_DatosApunte
   Inserta o modifica la información de un apunte manual en la agenda de pólizas en función del parámetro de entrada pmodo
   param in Pnpoliza: nº de póliza relacionada al apunte
   param in Psseguro: id. del seguro relacionado al apunte
   param in Pnlinea: nº de apunte relacionado a la póliza
   param in Pttitulo: Título del apunte en la agenda
   param in Pttextos: Texto del apunte en la agenda
   param in Pctipreg: concepto del apunte
   param in Pcestado: estado del apunte (0:Pendiente, 1:Finalizado, 2:Anulado). Por defecto 0.
   param in Pfapunte: fecha alta del apunte. Por defecto f_sysdate.
   param in Pffinali: fecha finalización del apunte. Por defecto NULL
   param in Pmodo in NUMBER: modo de acceso a la función (0:Alta, 1:Modificación)
   param in Pcmanual in NUMBER: indica si el apunte es automático o manual (0:Automático, 1:Manual)
   return           : 0 si ha ido bien
                      numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_datosapunte (
      pnpoliza   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnlinea    IN   NUMBER,
      pttitulo   IN   VARCHAR2,
      pttextos   IN   VARCHAR2,
      pctipreg   IN   NUMBER,
      pcestado   IN   NUMBER,
      pfapunte   IN   DATE,
      pffinali   IN   DATE,
      pmodo      IN   NUMBER,
      pcmanual   IN   NUMBER DEFAULT 1,
      pmode      IN   VARCHAR2 DEFAULT 'POL'
   )
      RETURN NUMBER
   IS
      vpasexec       NUMBER (8)             := 1;
      vparam         VARCHAR2 (5000)
         :=    'npoliza:'
            || pnpoliza
            || ' ,sseguro:'
            || psseguro
            || ' ,nlinea:'
            || pnlinea
            || ' , ttitulo:'
            || pttitulo
            || ' , ttextos:'
            || SUBSTR (pttextos, 1, 2000)
            || ' , ctipreg:'
            || pctipreg
            || ' ,cestado:'
            || pcestado
            || ' ,fapunte:'
            || pfapunte
            || ' ,ffinali:'
            || pffinali
            || ' , modo:'
            || pmodo
            || ' ,pcmanual:'
            || pcmanual;
      vobject        VARCHAR2 (500)        := 'PAC_AGENSEGU.F_SET_DATOSAPUNTE';
      v_nlinea       agensegu.nlinea%TYPE;
      vcestado_ant   NUMBER (1);
   --
   BEGIN
      vpasexec := 2;

      IF psseguro IS NULL
      THEN
         vpasexec := 3;
         RETURN (9000916);                        -- Assegurança obligatòria.
      END IF;

      IF pmodo = 0
      THEN
         -- Alta agenda
         vpasexec := 4;

         IF pmode = 'POL'
         THEN
            BEGIN
               --CONF 108 AP
               SELECT NVL (MAX (nlinea), 0) + 1
                 INTO v_nlinea
                 FROM agensegu
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT NVL (MAX (nlinea), 0) + 1
                       INTO v_nlinea
                       FROM agensegu
                      WHERE sseguro = (SELECT sseguro
                                         FROM seguros
                                        WHERE npoliza = pnpoliza);
                  END;
            END;

            vpasexec := 5;

            -- Realizamos el INSERT en la tabla AGENSEGU
            BEGIN
               INSERT INTO agensegu
                           (sseguro, nlinea, falta, ctipreg,
                            cestado, ttitulo, ttextos,
                            cmanual, ffinali
                           )
                    VALUES (psseguro, v_nlinea, pfapunte, pctipreg,
                            DECODE (pcmanual, 0, 1, 0), pttitulo, pttextos,
                            pcmanual, DECODE (pcmanual, 0, pfapunte, NULL)
                           );

               vpasexec := 6;
            EXCEPTION
               -- INI IAXIS-13888 -- 22/05/2020
               WHEN DUP_VAL_ON_INDEX
               THEN
                  BEGIN
                     INSERT INTO agensegu
                                 (sseguro, nlinea, falta,
                                  ctipreg, cestado,
                                  ttitulo, ttextos, cmanual,
                                  ffinali
                                 )
                          VALUES (psseguro, v_nlinea + 1, pfapunte,
                                  pctipreg, DECODE (pcmanual, 0, 1, 0),
                                  pttitulo, pttextos, pcmanual,
                                  DECODE (pcmanual, 0, pfapunte, NULL)
                                 );
                  END;
               -- IAXIS-13888 -- 22/05/2020
               WHEN OTHERS
               THEN
                  vpasexec := 7;
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                               SQLERRM
                              );
                  RETURN (103358);    -- Error insertando en la tabla AGENSEGU
            END;
         ELSE
            v_nlinea := 1;
            vpasexec := 5;

            -- Realizamos el INSERT en la tabla AGENSEGU
            BEGIN
               INSERT INTO estagensegu
                           (sseguro,
                            nlinea, falta, ctipreg,
                            cestado, ttitulo, ttextos,
                            cmanual, ffinali
                           )
                    VALUES (NVL ((SELECT sseguro
                                    FROM seguros
                                   WHERE npoliza = pnpoliza), psseguro),
                            v_nlinea, pfapunte, pctipreg,
                            DECODE (pcmanual, 0, 1, 0), pttitulo, pttextos,
                            pcmanual, DECODE (pcmanual, 0, pfapunte, NULL)
                           );

               vpasexec := 6;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  vpasexec := 66;

                  UPDATE estagensegu
                     SET nlinea = v_nlinea,
                         falta = pfapunte,
                         ctipreg = pctipreg,
                         cestado = DECODE (pcmanual, 0, 1, 0),
                         ttitulo = pttitulo,
                         ttextos = pttextos,
                         cmanual = pcmanual,
                         ffinali = DECODE (pcmanual, 0, pfapunte, NULL)
                   WHERE sseguro = NVL ((SELECT sseguro
                                           FROM seguros
                                          WHERE npoliza = pnpoliza), psseguro);
               WHEN OTHERS
               THEN
                 p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                               SQLERRM||' psseguro '||psseguro||'pnpoliza '||pnpoliza||'pttextos'||pttextos||'pttitulo'||pttitulo||'pmode '||pmode
                              );
            END;
         END IF;                                                 --CONF 108 AP
      ELSIF pmodo = 1
      THEN
         -- Modificació agenda
         vpasexec := 8;

         IF pmode = 'POL'
         THEN                                                   --CONF 108 AP
            BEGIN
               BEGIN
                  SELECT cestado
                    INTO vcestado_ant
                    FROM agensegu
                   WHERE sseguro = psseguro AND nlinea = pnlinea;

                  vpasexec := 9;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     vpasexec := 10;
                     vcestado_ant := NULL;
               END;

               IF vcestado_ant = 1 AND pcestado != 2
               THEN                             --BUG 11177 - JTS - 10/11/2009
                  vpasexec := 11;
                  RETURN (9001724);     --L'estat de l'agenda està finalitzat
               END IF;

               vpasexec := 12;

               -- Realizamos el UPDATE en la tabla AGENSEGU
               UPDATE agensegu
                  SET ctipreg = pctipreg,
                      cestado = pcestado,
                      ttitulo = pttitulo,
                      ffinali = pffinali,
                      ttextos = pttextos
                WHERE sseguro = psseguro AND nlinea = pnlinea;

               vpasexec := 13;
            --
            EXCEPTION
               WHEN OTHERS
               THEN
                  vpasexec := 14;
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                               SQLERRM
                              );
                              p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                               SQLERRM||' psseguro '||psseguro||'pnpoliza '||pnpoliza||'pttextos'||pttextos||'pttitulo'||pttitulo
                              );
                  RETURN 9001151;       -- Error modificando la tabla AGENSEGU
            END;
         ELSE
            vpasexec := 95;                                    -- CONF-108 AP

            BEGIN
               SELECT cestado
                 INTO vcestado_ant
                 FROM agensegu
                WHERE sseguro = psseguro AND nlinea = pnlinea;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vpasexec := 10;
                  vcestado_ant := NULL;
            END;

            IF vcestado_ant = 1 AND pcestado != 2
            THEN
               p_control_error ('AP', '101', 'vcestado_ant ' || vcestado_ant);
               --BUG 11177 - JTS - 10/11/2009
               RETURN (9001724);        --L'estat de l'agenda està finalitzat
            END IF;

            vpasexec := 111;

            BEGIN
              begin
               SELECT NVL (MAX (nlinea), 0) + 1
                 INTO v_nlinea
                 FROM agensegu a, estseguros e
                WHERE e.ssegpol = a.sseguro AND e.sseguro = psseguro;
              exception when no_data_found then
                 v_nlinea := 1;
              end;
               p_control_error ('AP', '100', 'v_nlinea ' || v_nlinea||'psseguro '||psseguro);
               vpasexec := 112;

               -- Realizamos el insert en la tabla AGENSEGU
                BEGIN
                  INSERT INTO estagensegu
                              (sseguro,
                               nlinea, falta, ctipreg,
                               cestado, ttitulo,
                               ttextos, cmanual,
                               ffinali
                              )
                       VALUES (psseguro,
                               v_nlinea, pfapunte, pctipreg,
                               DECODE (pcmanual, 0, 1, 0), pttitulo,
                               pttextos, pcmanual,
                               DECODE (pcmanual, 0, pfapunte, NULL)
                              );
               END;
               -- IAXIS-13888 --22/05/2020
               BEGIN
                  INSERT INTO estagensegu
                              (sseguro,
                               nlinea, falta, ctipreg,
                               cestado, ttitulo,
                               ttextos, cmanual,
                               ffinali
                              )
                       VALUES (NVL ((SELECT sseguro
                                       FROM seguros
                                      WHERE npoliza = pnpoliza), psseguro),
                               v_nlinea, pfapunte, pctipreg,
                               DECODE (pcmanual, 0, 1, 0), pttitulo,
                               pttextos, pcmanual,
                               DECODE (pcmanual, 0, pfapunte, NULL)
                              );
-- INI IAXIS-13888 -- 22/05/2020
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     vpasexec := 113;

                     BEGIN
                        INSERT INTO estagensegu
                                    (sseguro,
                                     nlinea, falta, ctipreg,
                                     cestado, ttitulo,
                                     ttextos, cmanual,
                                     ffinali
                                    )
                             VALUES (NVL ((SELECT sseguro
                                             FROM seguros
                                            WHERE npoliza = pnpoliza),
                                          psseguro),
                                     v_nlinea + 1, pfapunte, pctipreg,
                                     DECODE (pcmanual, 0, 1, 0), pttitulo,
                                     pttextos, pcmanual,
                                     DECODE (pcmanual, 0, pfapunte, NULL)
                                    );
                     END;
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
-- IAXIS-13888 -- 22/05/2020               vpasexec := 6;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  vpasexec := 114;

                  UPDATE estagensegu
                     SET nlinea = v_nlinea,
                         falta = pfapunte,
                         ctipreg = pctipreg,
                         cestado = DECODE (pcmanual, 0, 1, 0),
                         ttitulo = pttitulo,
                         ttextos = pttextos,
                         cmanual = pcmanual,
                         ffinali = DECODE (pcmanual, 0, pfapunte, NULL)
                   WHERE sseguro = NVL ((SELECT sseguro
                                           FROM seguros
                                          WHERE npoliza = pnpoliza), psseguro);
            END;
         END IF;                                                -- CONF-108 AP
      ELSE
         --CONF 108 AP
         BEGIN
            BEGIN
               SELECT cestado
                 INTO vcestado_ant
                 FROM estagensegu
                WHERE sseguro = psseguro AND nlinea = pnlinea;

               vpasexec := 9;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vpasexec := 10;
                  vcestado_ant := NULL;
            END;

            IF vcestado_ant = 1 AND pcestado != 2
            THEN
               --BUG 11177 - JTS - 10/11/2009
               vpasexec := 11;
               RETURN (9001724);        --L'estat de l'agenda està finalitzat
            END IF;

            vpasexec := 12;

            -- Realizamos el UPDATE en la tabla AGENSEGU
            UPDATE estagensegu
               SET ctipreg = pctipreg,
                   cestado = pcestado,
                   ttitulo = pttitulo,
                   ffinali = pffinali,
                   ttextos = pttextos
             WHERE sseguro = NVL ((SELECT sseguro
                                     FROM seguros
                                    WHERE npoliza = pnpoliza), psseguro)
               AND nlinea = pnlinea;

            vpasexec := 13;
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               vpasexec := 14;
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            vparam,
                            SQLERRM
                           );
               RETURN 9001151;          -- Error modificando la tabla AGENSEGU
         END;
      END IF;

      --CONF 108 AP
      vpasexec := 15;
      RETURN (0);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         vpasexec := 16;
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_agensegu.f_set_datosapunte',
                      1,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );

         IF NVL (pmodo, 0) = 0
         THEN
            vpasexec := 17;
            RETURN (103358);         -- Error insertando en la tabla AGENSEGU
         ELSE
            vpasexec := 18;
            RETURN (9001151);          -- Error modificando la tabla AGENSEGU
         END IF;
   END f_set_datosapunte;

   FUNCTION f_anula_apunte (psseguro IN NUMBER, pnlinea IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)     := 10;
      vparam      VARCHAR2 (500)
                          := 'sseguro:' || psseguro || ' ,nlinea:' || pnlinea;
      vobject     VARCHAR2 (500) := 'PAC_AGENSEGU.F_ANULA_APUNTE';
      sw_existe   NUMBER;
   BEGIN
      IF psseguro IS NULL OR pnlinea IS NULL
      THEN
         RETURN 9000505;                            --Error faltan parametros
      END IF;

      vpasexec := 20;

      BEGIN
         SELECT COUNT (*)
           INTO sw_existe
           FROM agensegu
          WHERE sseguro = psseguro AND nlinea = pnlinea;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 111360;                             -- La póliza no existe
      END;

      IF sw_existe = 0
      THEN
         -- No se ha encontrado el registro
         RETURN 9001152;
      END IF;

      vpasexec := 30;

      UPDATE agensegu
         SET cestado = 2
       WHERE sseguro = psseguro AND nlinea = pnlinea;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9001151;               -- Error modificando la tabla AGENSEGU
   END f_anula_apunte;
END pac_agensegu;
/
