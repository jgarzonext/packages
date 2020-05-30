CREATE OR REPLACE PACKAGE BODY pac_correo AS
/******************************************************************************
   NOMBRE:       pac_correo
   PROPÓSITO: Funciones de envio de coreo

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0
   1.1        09/03/2009  JSP              2. Modificaciones Bug 9208
   2.0        16/03/2009  DRA              0009423: IAX - Gestió propostes retingudes: detecció diferències al modificar capitals o afegir garanties
   3.0        06/07/2009  DCT              0010612: CRE - Error en la generació de pagaments automàtics.
                                           Canviar vista personas por tablas personas y añadir filtro de visión de agente
   4.0        07/09/2011   JMF             4. 0018967 LCOL_T005 - Listas restringidas validaciones y controles
   5.0        17/07/2012   JGR             5. 0022753: MDP_A001-Cierre de remesa
   6.0        05/02/2013   AMJ             6. 0025910: LCOL: Enviament de correu en el proc?s de liquidaci?
   7.0        01/03/2013   FAC             7. 0026209: LCOL_T010-LCOL - Soluci?n definitiva ejecuci?n de cartera desde pantalla
   8.0        02/09/2013   FAL             8. 0025720: RSAG998 - Numeración de pólizas por rangos
   9.0        04/02/2014   FAL             9. 0029965: RSA702 - GAPS renovación
   10.0       08/03/2019   CES             10. IAXIS-2420 Se agrega el procedimiento P_CAMBIO_REGIMEN para envio de corrreo en cambio de regimen simplificado a común.
   11.0       28/03/2019   JLTS            11. IAXIS-3363. Se agregaran parametros a las funciones f_cuerpo y f_mail
******************************************************************************/
-- INI IAXIS-3363 - JLTS - 28/03/2019
   FUNCTION f_data_rd (PSRDIAN IN rango_dian.srdian%TYPE, PNCAMPO IN NUMBER) 
	   RETURN VARCHAR2;
-- FIN IAXIS-3363 - JLTS - 28/03/2019

   FUNCTION f_origen(pscorreo IN NUMBER, p_from OUT VARCHAR2, paviso IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      IF paviso = 1 THEN
         p_from := NVL(f_parinstalacion_t('MAIL_FROM'), 'Crèdit');
      ELSE
         BEGIN
            SELECT remitente
              INTO p_from
              FROM mensajes_correo
             WHERE scorreo = pscorreo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 151425;   --No esixte ningún correo de este tipo .
         END;
      END IF;

      RETURN 0;
   END;

   FUNCTION f_destinatario(
      pscorreo IN NUMBER,
      psseguro IN NUMBER,
      p_to OUT VARCHAR2,
      p_to2 OUT VARCHAR2,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR destinatarios(p_scorreo IN NUMBER) IS
         SELECT destinatario, descripcion, direccion
           FROM destinatarios_correo
          WHERE scorreo = p_scorreo;

      v_to           VARCHAR2(300);
      v_to2          VARCHAR2(300);
      vcagente       NUMBER;
   BEGIN
      FOR c IN destinatarios(pscorreo) LOOP
         IF c.direccion IS NULL THEN
            IF c.destinatario = 'OFICINA' THEN
               -- buscamos la direccion de la oficina de la poliza.
               IF pcmotmov = 225 THEN
                  BEGIN
                     SELECT sperson
                       INTO vcagente
                       FROM historicoseguros h, agentes p
                      WHERE h.cagente = p.cagente
                        AND h.sseguro = psseguro
                        AND h.nmovimi = (SELECT MAX(nmovimi)
                                           FROM historicoseguros h2
                                          WHERE h2.sseguro = h.sseguro);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RETURN 103286;   --El seguro no existe
                  END;
               ELSE
                  BEGIN
                     SELECT sperson
                       INTO vcagente
                       FROM seguros s, agentes a
                      WHERE s.sseguro = psseguro
                        AND a.cagente = s.cagente;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RETURN 103286;   --El seguro no existe
                  END;
               END IF;

               --La buscamos en contactos de la oficina es la
               -- primera dirección de correo que existe.
               BEGIN
                  SELECT tvalcon
                    INTO v_to
                    FROM contactos
                   WHERE sperson = vcagente
                     AND ctipcon = 3;
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     SELECT tvalcon
                       INTO v_to
                       FROM contactos
                      WHERE sperson = vcagente
                        AND ctipcon = 3
                        AND cmodcon = (SELECT MIN(cmodcon)
                                         FROM contactos
                                        WHERE sperson = vcagente
                                          AND ctipcon = 3);
                  WHEN OTHERS THEN
                     v_to := NULL;
               END;
            ELSIF c.destinatario = 'CONTACTO' THEN
               -- Obtenemos la direccion de correo de contactos.
               BEGIN
                  SELECT sperson
                    INTO vcagente
                    FROM seguros s, agentes a
                   WHERE sseguro = psseguro
                     AND a.cagente = s.cagente;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 103286;   --El seguro no existe
               END;
            -- BUG 29965 - FAL - 03/02/2014
            ELSIF c.destinatario = 'USUARIO' THEN
               BEGIN
                  SELECT mail_usu
                    INTO v_to
                    FROM movseguro m, usuarios u
                   WHERE m.sseguro = psseguro
                     AND m.nmovimi = 1
                     AND m.cusumov = u.cusuari;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 103286;   --El seguro no existe
               END;
            -- BUG 29965 - FAL - 03/02/2014
            END IF;
         ELSE
            v_to := c.direccion;
         END IF;

         -- Calculamos la descripción del Para
         IF c.destinatario = c.descripcion THEN
            v_to2 := v_to;
         ELSIF c.descripcion <> 'DIRECCION' THEN
            v_to2 := c.descripcion;
         END IF;

         IF v_to IS NOT NULL THEN
            p_to := RTRIM(v_to || ';' || p_to, ';');
            p_to2 := RTRIM(v_to2 || ';' || p_to2, ';');
         END IF;
      END LOOP;

      IF p_to IS NULL THEN   --No hemos entrado en el bucle
         RETURN 151423;   -- No se han encontrado destinatarios de correo
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_correo.destinatario', 1,
                     '{Error en el calculo del destinatario}', SQLERRM);
         RETURN 151907;   --{Error en el calculo del destinatario}
   END f_destinatario;

   FUNCTION f_cuerpo(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      ptexto OUT VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      ptcuerpo IN VARCHAR2 DEFAULT NULL,   -- 5. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
      pcramo IN NUMBER DEFAULT NULL,   -- BUG 25720 - FAL - 02/09/2013
			psrdian IN NUMBER DEFAULT NULL -- IAXIS-3363 - JLTS - 28/03/2019
                                   )
      RETURN NUMBER IS
      pos            NUMBER;
      v_cempres      NUMBER;   -- BUG 25720 - FAL - 02/09/2013
	  tot_capital    NUMBER;
      v_error        NUMBER;
   BEGIN
      BEGIN
         SELECT cuerpo
           INTO ptexto
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      --No existe ningún Subject para este tipo de correo.
      END;

      --sustitución de los npolizas de los mails
      pos := INSTR(ptexto, '#NPOLIZA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NPOLIZA#', f_poliza(psseguro));
      END IF;

      --sustitución de los ncertificado de los mails
      pos := INSTR(ptexto, '#CERTIFICADO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CERTIFICADO#', f_certificado(psseguro));
      END IF;

      --sustitución de los nsolici de los mails
      pos := INSTR(ptexto, '#NSOLICI#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NSOLICI#', f_solicitud(psseguro));
      END IF;

	  pos := INSTR(ptexto, '#TOMADOR#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#TOMADOR#', f_tomador(psseguro));
      END IF;

	  pos := INSTR(ptexto, '#ICAPITAL#', 1);

      IF pos > 0 THEN
         v_error := f_icapital(psseguro,tot_capital);
         ptexto := REPLACE(ptexto, '#ICAPITAL#', tot_capital);
      END IF;

	  pos := INSTR(ptexto, '#CESTADO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CESTADO#', f_estadopol(psseguro));
      END IF;

	  pos := INSTR(ptexto, '#SUSCRIPTOR#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#SUSCRIPTOR#', f_usuariopol(psseguro)) ;
      END IF;

      --sustitución de las clauslas de los mails
      pos := INSTR(ptexto, '#CLAUSULA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CLAUSULA#', f_clausula(psseguro));
      END IF;

      --sustitución de las clauslas de los mails
      pos := INSTR(ptexto, '#SOBREPRIMA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#SOBREPRIMA#', f_sobreprima(psseguro, pnriesgo, pcidioma));
      END IF;

      --sustitución de las garantias excluídas
      pos := INSTR(ptexto, '#GARANTIAS#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#GARANTIAS#', f_garantias(psseguro, pnriesgo, pcidioma));
      END IF;

--sustitución del nombre del asegurado
-------------------------------------------------------------------------
      pos := INSTR(ptexto, '#ASEGURADO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#ASEGURADO#', f_assegurado(psseguro, pnriesgo));
      END IF;

-------------------------------------------------------------------------
           --sustitución de las pruebas a realizar
      pos := INSTR(ptexto, '#PRUEBA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#PRUEBA#', f_pruebas(psseguro, pnriesgo, pcidioma));
      END IF;

      --sustitución de los telefonos de contacto de la poliza
      pos := INSTR(ptexto, '#CONTACTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CONTACTO#', f_contactos(psseguro, pnriesgo));
      END IF;

      --sustitución de los beneficiarios
      pos := INSTR(ptexto, '#BENEFICIARIOS#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#BENEFICIARIOS#',
                           f_beneficiarios(psseguro, pnriesgo, pcidioma));
      END IF;

      --sustitución de los benef con movimiento
      pos := INSTR(ptexto, '#BENEFICIMOV#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#BENEFICIMOV#', f_benefmov(psseguro, pnriesgo, pcidioma));
      END IF;

      --sustitución de los beneficiario irrev.
      pos := INSTR(ptexto, '#BENEFIRREV#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#BENEFIRREV#', f_benefirrev(psseguro, pnriesgo, pcidioma));
      END IF;

      --sustitución de los datos de la oficina
      pos := INSTR(ptexto, '#OFICINA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#OFICINA#', f_oficina(psseguro, pnriesgo));
      END IF;

      pos := INSTR(ptexto, '#RECHAZO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#RECHAZO#', f_rechazo(psseguro, pnriesgo, pcidioma));   -- BUG 29965 - FAL - 07/02/2014.
      END IF;

      pos := INSTR(ptexto, '#NSINIES#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NSINIES#', pnsinies);
      END IF;

      --sustitución de los datos de la oficina gestión
      pos := INSTR(ptexto, '#GESTION#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#GESTION#', f_gestion(psseguro));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(ptexto, '#MOVIMIENTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#MOVIMIENTO#', f_movimiento(pcmotmov, pcidioma));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(ptexto, '#TIPOMOV#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#TIPOMOV#', f_tipomov(pcmotmov, pcidioma, 0));
      END IF;

      --sustitución de los datos del ramo
      pos := INSTR(ptexto, '#RAMO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#RAMO#', f_ramo(psseguro, pcidioma));
      END IF;

      --sustitución del nif del asegurado
      pos := INSTR(ptexto, '#NIFASEGURADO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NIFASEGURADO#', f_nif(psseguro, pnriesgo));
      END IF;

      --sustitución del nif del asegurado
      pos := INSTR(ptexto, '#RIESGO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#RIESGO#', f_riesgo(psseguro, pnriesgo, pcidioma));
      END IF;

      --sustitución de la ofi. tramitadora
      pos := INSTR(ptexto, '#OFITRAMITADORA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#OFITRAMITADORA#', f_tramitadora);
      END IF;

      --sustitución de la matrícula del gestor
      pos := INSTR(ptexto, '#MATRICGESTOR#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#MATRICGESTOR#', f_user);
      END IF;

      --sustitución de la descripción del producto
      pos := INSTR(ptexto, '#PRODUCTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#PRODUCTO#', f_producto(psseguro, pcidioma));
      END IF;

      --sustitución de la fecha de alta solicitud
      pos := INSTR(ptexto, '#FALTA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FALTA#', f_falta(psseguro));
      END IF;

      --sustitución de la nueva nsolicit que reemplaza
      pos := INSTR(ptexto, '#NSOLICIREEMPL#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NSOLICIREEMPL#', f_solicitud_reempl(psseguro));
      END IF;

      -- Sustitucion de la fecha efecto de la póliza
      pos := INSTR(ptexto, '#FEFECTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FEFECTO#', f_fefecto(psseguro));
      END IF;

      -- Sustitucion de la fecha cancelacion de la póliza
      pos := INSTR(ptexto, '#FCANCEL#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FCANCEL#', f_fcancel(psseguro));
      END IF;

      -- BUG 25720 - FAL - 02/09/2013
      -- Sustitucion del nº polizas disponibles segun rango(s)
      IF pcramo IS NOT NULL THEN
         SELECT cempres
           INTO v_cempres
           FROM codiram
          WHERE cramo = pcramo;

         pos := INSTR(ptexto, '#CONTPOL#', 1);

         IF pos > 0 THEN
            ptexto := REPLACE(ptexto, '#CONTPOL#',
                              pac_propio.f_get_numpol_dispo(v_cempres, '02', pcramo));
         END IF;
      END IF;
      -- FI BUG 25720 - FAL - 02/09/2013
      -- INI IAXIS-3363 - JLTS - 28/03/2019
      -- Sustitucion de los datos del cuerpo para RANGOS DIAN
      IF psrdian is not null then 
        DECLARE
          v_01 CONSTANT VARCHAR2(20) := '#SUCURSAL_RD#';
          v_02 CONSTANT VARCHAR2(20) := '#PRODUCTO_RD#';
          v_03 CONSTANT VARCHAR2(20) := '#RESOLUCION_RD#';
          v_04 CONSTANT VARCHAR2(20) := '#FECHA_RD#';
        BEGIN
          pos := instr(ptexto,v_01, 1);
        
          IF pos > 0 THEN
            ptexto := REPLACE(ptexto, v_01, f_data_rd(psrdian,1));
          END IF;
        
          pos := instr(ptexto, v_02, 1);
        
          IF pos > 0 THEN
            ptexto := REPLACE(ptexto, v_02, f_data_rd(psrdian,2));
          END IF;
        
          pos := instr(ptexto, v_03, 1);
        
          IF pos > 0 THEN
            ptexto := REPLACE(ptexto, v_03, f_data_rd(psrdian,3));
          END IF;
        
          pos := instr(ptexto, v_04, 1);
        
          IF pos > 0 THEN
            ptexto := REPLACE(ptexto, v_04, f_data_rd(psrdian,4));
          END IF;
        END;
      END IF;
      -- FIN IAXIS-3363 - JLTS - 28/03/2019

      --sustitución de valores libres #N#
      IF ptcuerpo IS NOT NULL THEN
         ptexto := f_reemplaza_valores(ptexto, ptcuerpo);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 152556;   -- Error en el cuerpo del mensaje
   END f_cuerpo;

   FUNCTION f_asunto(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      psubject OUT VARCHAR2,
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      ptasunto IN VARCHAR2
            DEFAULT NULL   -- 5. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
                        )
      RETURN NUMBER IS
      pos            NUMBER;
      tot_capital    NUMBER;
      v_error        NUMBER;
   BEGIN
      BEGIN
         SELECT asunto
           INTO psubject
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      --No esixte ningún Subject para este tipo de correo.
      END;

      --sustitución de los npolizas de los mails
      pos := INSTR(psubject, '#NPOLIZA#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NPOLIZA#', f_poliza(psseguro));
      END IF;

      --sustitución de los ncertificado de los mails
      pos := INSTR(psubject, '#CERTIFICADO#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#CERTIFICADO#', f_certificado(psseguro));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#MOVIMIENTO#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#MOVIMIENTO#', f_tipomov(pcmotmov, pcidioma, 1));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#NSOLICI#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NSOLICI#', f_solicitud(psseguro));
      END IF;

	  pos := INSTR(psubject, '#TOMADOR#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#TOMADOR#', f_tomador(psseguro));
      END IF;

	  pos := INSTR(psubject, '#ICAPITAL#', 1);

      IF pos > 0 THEN
         v_error := f_icapital(psseguro,tot_capital);
         psubject := REPLACE(psubject, '#ICAPITAL#', tot_capital);
      END IF;

	  pos := INSTR(psubject, '#CESTADO#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#CESTADO#', f_estadopol(psseguro));
      END IF;

	  pos := INSTR(psubject, '#SUSCRIPTOR#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#SUSCRIPTOR#', f_usuariopol(psseguro)) ;
      END IF;

      --sustitución de valor libre #1
      IF ptasunto IS NOT NULL THEN
         pos := INSTR(psubject, '#1#', 1);

         IF pos > 0 THEN
            psubject := REPLACE(psubject, '#1#', ptasunto);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 180285;   -- Error en el Subject del mensaje
   END f_asunto;

   FUNCTION f_mail(
      pscorreo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcidioma IN NUMBER,
      pcaccion IN VARCHAR2,
      pmail OUT VARCHAR2,
      pasunto OUT VARCHAR2,
      pfrom OUT VARCHAR2,
      pto OUT VARCHAR2,
      pto2 OUT VARCHAR2,
      perror OUT VARCHAR2,
      pnsinies IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      paviso IN NUMBER DEFAULT NULL,
      ptasunto IN VARCHAR2 DEFAULT NULL,   -- 5. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
      ptcuerpo IN VARCHAR2 DEFAULT NULL,   -- 5. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
      pcramo IN NUMBER DEFAULT NULL,       -- BUG 25720 - FAL - 02/09/2013
      pdestino IN VARCHAR2 DEFAULT NULL,
			psrdian IN NUMBER DEFAULT NULL) -- IAXIS-3363 - JLTS - 28/03/2019
      RETURN NUMBER IS
         /*******************************************************************************
            5-4-2006. Se modifica el tipo de registro de la agenda (detvalores 21)
                        Antes 5 (automático)
                     Ahora 30  (envío mail)
      ********************************************************************************/
      num_err        NUMBER;
      v_subject      VARCHAR2(250);
      v_from         VARCHAR2(300);
      v_to           VARCHAR2(300);
      v_to2          VARCHAR2(300);
      v_texto        VARCHAR2(4000);   -- BUG9423:12/03/2009:DRA: Ampliamos a 4000
      persona        NUMBER;
   BEGIN
      -- Obtenemos el asunto
      num_err := f_asunto(pscorreo, pcidioma, v_subject, psseguro, pcmotmov, ptasunto);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --Obtenemos el origen
      num_err := f_origen(pscorreo, v_from, paviso);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --Obtenemos los detinatarios
      IF pdestino IS NULL THEN
          num_err := f_destinatario(pscorreo, psseguro, v_to, v_to2, pcmotmov);

          IF num_err <> 0 THEN
             RETURN num_err;
          END IF;
      ELSE
          v_to :=  pdestino;
          v_to2 := pdestino;
      END IF;

      -- Obtenemos el cuerpo del correo
      num_err := f_cuerpo(pscorreo, pcidioma, v_texto, psseguro, pnriesgo, pnsinies, pcmotmov,
                          ptcuerpo, pcramo, psrdian);   -- BUG 25720 - FAL - 02/09/2013 - Añade param pcramo

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --enviamos el correo
      pmail := v_texto;
      pasunto := v_subject;
      pfrom := v_from;
      pto := v_to;
      pto2 := v_to2;

      IF NVL(pcaccion, 'REAL') <> 'SIMULACION' THEN
         -- 5. 0022753: MDP_A001-Cierre de remesa - Inicio
         IF psseguro IS NULL
            OR pnriesgo IS NULL THEN
            p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);
         ELSE
            -- 5. 0022753: MDP_A001-Cierre de remesa - Fin

            --obtenemos el sperson del aseguarado para realizar el apunte en la agenda
            BEGIN
               SELECT sperson
                 INTO persona
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  perror := SQLERRM;
                  p_tab_error(f_sysdate, f_user, 'correo', NULL, '{INVALID MAIL222}', SQLERRM);
                  RETURN 151909;
            END;

            p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);
            -- anotamos en la agenda
            --BUG9208-28052009-XVM
            num_err := pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL,
                                                      SUBSTR('MAIL:' || v_subject, 0, 20),
                                                      v_texto, 30, 1, TRUNC(f_sysdate),
                                                      TRUNC(f_sysdate), 0, 0);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
/*
         -- reaprovechamos el campo CSUBTIP para poner el identificador de correo enviado.
         BEGIN
            UPDATE agensegu
               SET csubtip = pscorreo
             WHERE sseguro = psseguro
               AND sagenda = (SELECT MAX(sagenda)
                                FROM agensegu
                               WHERE sseguro = psseguro);
         EXCEPTION
            WHEN OTHERS THEN
               perror := SQLERRM;
               p_tab_error(f_sysdate, f_user, 'correo', NULL, '{INVALID MAL222}', SQLERRM);
               RETURN 151909;
         END;
*/
         END IF;   -- 5. 0022753: MDP_A001-Cierre de remesa (+)
      END IF;

      perror := 0;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         perror := SQLERRM;
         p_tab_error(f_sysdate, f_user, 'correo', NULL, '{INVALID MAIL}', SQLERRM);
         RETURN 151909;   --{INVALID MAIL}
   END f_mail;

   FUNCTION f_poliza(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(10);
   BEGIN
      BEGIN
         SELECT npoliza
           INTO resultado
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            resultado := 'XXXXXXXXX';
      END;

      RETURN resultado;
   END f_poliza;

   FUNCTION f_certificado(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(10);
   BEGIN
      BEGIN
         SELECT ncertif
           INTO resultado
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            resultado := 'XXXXXXXXX';
      END;

      RETURN resultado;
   END f_certificado;

   FUNCTION f_solicitud(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(10);
   BEGIN
      BEGIN
         SELECT nsolici
           INTO resultado
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            resultado := 'XXXXXXXXX';
      END;

      RETURN resultado;
   END f_solicitud;

   FUNCTION f_clausula(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(4000);

      CURSOR clausulas IS
         SELECT tclaesp, nordcla
           FROM clausuesp
          WHERE cclaesp = 2
            AND sseguro = psseguro
            AND ffinclau IS NULL;
   BEGIN
      -- BUG9423:12-03-2009:DRA: Formateamos el texto
      FOR c IN clausulas LOOP
         resultado := resultado || '    ' || c.nordcla || '.- ' || c.tclaesp || CHR(10);
      END LOOP;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_clausula;

   FUNCTION f_sobreprima(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER DEFAULT 2)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(2000);
      prima          NUMBER;
      diferentes     NUMBER := 0;
      ttexto         VARCHAR2(50);
      num_err        NUMBER;
      desgar         VARCHAR2(50);
      --v_lit_cap      VARCHAR2(200);
      v_lit_sob      VARCHAR2(400);

      CURSOR gar IS
         SELECT cgarant, precarg, icapital
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND ffinefe IS NULL;
   -- BUG9423:12-03-2009:DRA:Ahora mostraremos todas las garantías
   /*AND (    precarg IS NOT NULL
        AND precarg <> 0);*/
   BEGIN
      -- BUG9423:12-03-2009:DRA:Ahora mostraremos todas las garantías
      /*BEGIN
         SELECT DISTINCT NVL (precarg, 0)
                    INTO resultado
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND ffinefe IS NULL
                     AND nriesgo = pnriesgo;

         p_literal2 (151992, pcidioma, ttexto);
         resultado := resultado || ' % ' || ttexto;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            diferentes := 1;
      END;*/

      -- BUG9423:17/03/2009:DRA:Afegim el capital de les garanties: Inici
      -- p_literal2(101670, pcidioma, v_lit_cap);
      v_lit_sob := f_axis_literales(101671, pcidioma);

      -- IF diferentes = 1 THEN
      FOR reg IN gar LOOP
         num_err := f_desgarantia(reg.cgarant, pcidioma, desgar);
         -- BUG9423:DRA:23/4/2009: volem que surti així
         --   Mort: 6.000,00 - Sobreprima = 0,00 %.
         resultado := resultado || '    ' || desgar || ': '   -- || v_lit_cap || ' = '
                      || TO_CHAR(NVL(reg.icapital, 0), 'FM999G999G990D00') || ' - '
                      || v_lit_sob || ' = '
                      || TO_CHAR(NVL(reg.precarg, 0), 'FM999G999G990D00') || ' %. ' || CHR(10);
      END LOOP;

      -- BUG9423:17/03/2009:DRA:Fi

      -- END IF;
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_sobreprima;

   FUNCTION f_assegurado(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(100);
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      BEGIN
         -- Bug10612 - 06/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         -- Nom del prenedor i npoliza
         SELECT s.cempres, s.cagente
           INTO vcempres, vagente_poliza
           FROM seguros s
          WHERE s.sseguro = psseguro;

         SELECT INITCAP(SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20) || ' '
                        || SUBSTR(d.tnombre, 0, 20)) asegurado
           INTO resultado
           FROM per_personas p, per_detper d, riesgos r
          WHERE p.sperson = d.sperson
            AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
            AND r.sseguro = psseguro
            AND r.sperson = p.sperson
            AND r.nriesgo = pnriesgo;
      /*SELECT INITCAP(tapelli || ' ' || tnombre) asegurado
        INTO resultado
        FROM personas p, riesgos r
       WHERE sseguro = psseguro
         AND r.sperson = p.sperson
         AND r.nriesgo = pnriesgo;*/
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN resultado;
   END f_assegurado;

   FUNCTION f_pruebas(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      CURSOR motivos_ret IS
         SELECT cmotret
           FROM motretencion
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = psseguro);

      resultado      VARCHAR2(1000);
      ttexto         VARCHAR2(100);
      num_err        NUMBER;
   BEGIN
      FOR i IN motivos_ret LOOP
         num_err := f_desvalorfijo(708, pcidioma, i.cmotret, ttexto);
         resultado := resultado || ' ' || ttexto || CHR(13);
      END LOOP;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_pruebas;

   FUNCTION f_contactos(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2 IS
      CURSOR telefonos IS
         SELECT   cmodcon, tvalcon
             FROM contactos c, riesgos r
            WHERE c.sperson = r.sperson
              AND r.sseguro = psseguro
              AND r.nriesgo = pnriesgo
              AND c.ctipcon = 1
              AND tvalcon <> '00'
         ORDER BY cmodcon;

      resultado      VARCHAR2(1000);
   BEGIN
      FOR c IN telefonos LOOP
         resultado := resultado || ' ' || c.tvalcon || CHR(13);
      END LOOP;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_contactos;

   FUNCTION f_beneficiarios(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(600);
   BEGIN
      BEGIN
         SELECT ttexto
           INTO resultado
           FROM (SELECT LOWER(tclaben) ttexto
                   FROM claubenseg c, clausuben x
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND ffinclau IS NULL
                    AND x.sclaben = c.sclaben
                    AND cidioma = pcidioma
                 UNION
                 SELECT LOWER(tclaesp) ttexto
                   FROM clausuesp
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND ffinclau IS NULL);
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            RETURN 101965;
      END;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_beneficiarios;

   ---
   FUNCTION f_benefmov(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vtexto         VARCHAR2(100) := '';
      vtexto2        VARCHAR2(200) := '';
      resultado      VARCHAR2(300);
   BEGIN
      IF pac_avisos.f_benefirrevocable(psseguro, pnriesgo, 5) = 1 THEN
         SELECT DECODE
                   (pcidioma,
                    1, 'Beneficiari preferent irrevocable la Caixa de Balears pel deute pendent.',
                    2, 'Beneficiario preferente irrevocable la Caixa de Balears por la deuda pendiente.')
           INTO vtexto
           FROM DUAL;
      END IF;

      BEGIN
         SELECT TRANSLATE(ttexto, CHR(13) || CHR(10), ', ')
           INTO vtexto2
           FROM (SELECT x.tclaben ttexto   --Lower
                   FROM claubenseg c, clausuben x
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND ffinclau IS NULL
                    AND x.sclaben = c.sclaben
                    AND cidioma = pcidioma
                 UNION
                 SELECT tclaesp ttexto
                   FROM clausuesp
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND sclagen IS NULL
                    AND ffinclau IS NULL);
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            RETURN 101965;
      END;

      IF vtexto IS NULL THEN
         resultado := vtexto2;
      ELSE
         resultado := vtexto || CHR(13) || vtexto2;
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_benefmov;

   ---
   FUNCTION f_oficina(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(100);

      CURSOR direcciones(pcagente IN NUMBER) IS
         SELECT d.tdomici contactos
           FROM direcciones d, agentes a
          WHERE d.sperson = a.sperson
            AND a.cagente = pcagente
         UNION
         SELECT 'Telf.- ' || d.tvalcon contactos
           FROM contactos d, agentes a
          WHERE d.sperson = a.sperson
            AND a.cagente = pcagente
            AND d.ctipcon = 1
            AND d.tvalcon <> '00';

      vagente        NUMBER;
   BEGIN
      BEGIN
         -- Bug10612 - 06/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20) || ' '
                || SUBSTR(d.tnombre, 0, 20),
                s.cagente
           INTO resultado,
                vagente
           FROM per_detper d, agentes a, seguros s
          WHERE a.cagente = s.cagente
            AND s.sseguro = psseguro
            AND a.sperson = d.sperson;   -- sOLO PUEDE TENER UN REGISTRO PK UN AGENTE ES UNA PERSONA PÚBLICA Y SOLO TIENE UN DETALLE
            --AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres);
      /*SELECT tapelli || ' ' || tnombre, s.cagente
        INTO resultado, vagente
        FROM personas p, agentes a, seguros s
       WHERE p.sperson = a.sperson
         AND a.cagente = s.cagente
         AND s.sseguro = psseguro;*/
      EXCEPTION
         WHEN OTHERS THEN
            resultado := ' Anonymous';
      END;

      FOR d IN direcciones(vagente) LOOP
         resultado := resultado || CHR(13) || ' ' || d.contactos;
      END LOOP;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_oficina;

   FUNCTION f_garantias(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(2000);
      num_err        NUMBER;
      vgarant        VARCHAR2(100);

      CURSOR garantias IS
         SELECT cgarant
           FROM exclugarseg
          WHERE nriesgo = pnriesgo
            AND sseguro = psseguro
            AND nmovimb IS NULL;
   BEGIN
      FOR c IN garantias LOOP
         num_err := f_desgarantia(c.cgarant, pcidioma, vgarant);
         resultado := resultado || c.cgarant || '.-' || vgarant || CHR(13);
      END LOOP;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_garantias;

   FUNCTION f_rechazo(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)   -- BUG 29965 - FAL - 07/02/2014
      RETURN VARCHAR2 IS
      resultado      motreten_rev.tobserva%TYPE;   -- BUG9423:DRA:03-04-2009
   BEGIN
      BEGIN
         SELECT LOWER(tobserva)
           INTO resultado
           FROM motreten_rev
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND cresulta = 2   --{Rechazo}
            AND nmotrev = pac_motretencion.f_max_nmotrev(sseguro, nmovimi, nriesgo, cmotret,
                                                         nmotret)
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- BUG 29965 - FAL - 07/02/2014
            --NULL;
            BEGIN
               SELECT m.tmotmov
                 INTO resultado
                 FROM motanumov a, motmovseg m
                WHERE a.sseguro = psseguro
                  AND a.cmotmov = m.cmotmov
                  AND m.cidioma = pcidioma
                  AND a.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro
                                    WHERE sseguro = psseguro);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
      -- FI BUG 29965
      END;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, '{pac_correo.f_rechazo}', 1,
                     '{Error en el calculo del motivo de rechazo}', SQLERRM);
         RETURN 151910;   --{Error en el calculo del motivo de rechazo}
   END f_rechazo;

   FUNCTION f_gestion(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(2000);
   BEGIN
      -- Bug10612 - 06/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
      SELECT a.cagente || '-' || SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20)
        INTO resultado
        FROM seguros s, agentes a, per_detper d
       WHERE s.cagente = a.cagente
         AND s.sseguro = psseguro
         AND d.sperson = a.sperson;

      /*SELECT a.cagente || '-' || tapelli
        INTO resultado
        FROM seguros s, agentes a, personas p
       WHERE s.cagente = a.cagente
         AND a.sperson = p.sperson
         AND s.sseguro = psseguro;*/
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_gestion;

   FUNCTION f_movimiento(pcmotmov IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(200);
   BEGIN
      SELECT tmotmov
        INTO resultado
        FROM motmovseg
       WHERE cmotmov = pcmotmov
         AND cidioma = pcidioma;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_movimiento;

   FUNCTION f_tipomov(pcmotmov IN NUMBER, pcidioma IN NUMBER, pasunto IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(200);
   BEGIN
      IF pcmotmov IN(221, 301, 306) THEN
         IF pasunto = 1 THEN
            SELECT DECODE(pcidioma, 1, 'Anul.lació', 2, 'Anulación')
              INTO resultado
              FROM DUAL;
         ELSE
            SELECT DECODE(pcidioma, 1, 'l''anul.lació', 2, 'la anulación')
              INTO resultado
              FROM DUAL;
         END IF;
      ELSIF pcmotmov IN(820) THEN
         IF pasunto = 1 THEN
            SELECT DECODE(pcidioma, 1, 'Modif.Beneficiari', 2, 'Modif.Beneficiario')
              INTO resultado
              FROM DUAL;
         ELSE
            SELECT DECODE(pcidioma,
                          1, 'modificar el beneficiari',
                          2, 'modificar el beneficiario')
              INTO resultado
              FROM DUAL;
         END IF;
      ELSIF pcmotmov IN(225) THEN
         IF pasunto = 1 THEN
            SELECT DECODE(pcidioma, 1, 'Modif.Oficina Gestió', 2, 'Modif.Oficina Gestión')
              INTO resultado
              FROM DUAL;
         ELSE
            SELECT DECODE(pcidioma,
                          1, 'la modificació de l''oficina de gestió',
                          2, 'la modificación de la oficina de gestión')
              INTO resultado
              FROM DUAL;
         END IF;
      ELSIF pcmotmov IN(281) THEN
         IF pasunto = 1 THEN
            SELECT DECODE(pcidioma, 1, 'Minoració Capitals', 2, 'Minoración Capitales')
              INTO resultado
              FROM DUAL;
         ELSE
            SELECT DECODE(pcidioma,
                          1, 'una minoració de garanties',
                          2, 'una minoración de garantías')
              INTO resultado
              FROM DUAL;
         END IF;
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tipomov;

   FUNCTION f_ramo(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(2000);
      num_err        NUMBER := 0;
      vcramo         NUMBER;
      vdescrip       VARCHAR2(100);
   BEGIN
      SELECT cramo
        INTO vcramo
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := f_desramo(vcramo, pcidioma, vdescrip);

      IF num_err = 0 THEN
         resultado := vcramo || '-' || vdescrip;
      ELSE
         resultado := NULL;
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_ramo;

/*   FUNCTION f_nif (
      psseguro   IN   NUMBER)
      RETURN VARCHAR2 IS
      resultado    VARCHAR2 (30);
   BEGIN
      SELECT nnumnif
        INTO resultado
        FROM personas p, asegurados a
       WHERE sseguro = psseguro
         AND a.sperson = p.sperson;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END f_nif;
*/
   FUNCTION f_nif(psseguro IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(30);
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      -- Bug10612 - 06/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
      -- Nom del prenedor i npoliza
      SELECT s.cempres, s.cagente
        INTO vcempres, vagente_poliza
        FROM seguros s
       WHERE s.sseguro = psseguro;

      SELECT nnumide
        INTO resultado
        FROM per_personas p, riesgos r
       WHERE sseguro = psseguro
         AND r.sperson = p.sperson
         AND r.nriesgo = pnriesgo;

      /*SELECT nnumnif
        INTO resultado
        FROM personas p, riesgos r
       WHERE sseguro = psseguro
         AND r.sperson = p.sperson
         AND r.nriesgo = pnriesgo;*/
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_nif;

   FUNCTION f_riesgo(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(100);
      num_err        NUMBER;
      ptriesgo1      VARCHAR2(100);
      ptriesgo2      VARCHAR2(100);
      ptriesgo3      VARCHAR2(100);
   BEGIN
      num_err := f_desriesgo(psseguro, pnriesgo, f_sysdate, pcidioma, ptriesgo1, ptriesgo2,
                             ptriesgo3);

      IF num_err <> 0 THEN
         resultado := NULL;
      ELSE
         resultado := ptriesgo1;

         IF ptriesgo2 IS NOT NULL THEN
            resultado := resultado || ' ' || ptriesgo2;
         END IF;

         IF ptriesgo3 IS NOT NULL THEN
            resultado := resultado || ' ' || ptriesgo3;
         END IF;
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_riesgo;

   FUNCTION f_benefirrev(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(300);
   BEGIN
      IF pac_avisos.f_benefirrevocable(psseguro, pnriesgo, 5) = 1 THEN
         SELECT DECODE(pcidioma,
                       1, 'Entitat beneficiaria: CAMPB',
                       2, 'Entidad beneficiaria: CAMPB')
           INTO resultado
           FROM DUAL;

         resultado := resultado || CHR(13);
      ELSE
         resultado := '';
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_benefirrev;

   FUNCTION f_tramitadora
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(2000);
   BEGIN
      SELECT a.cagente || '-' || tapelli
        INTO resultado
        FROM usuarios u, agentes a, personas p
       WHERE u.cdelega = a.cagente
         AND a.sperson = p.sperson
         AND u.cusuari = f_user;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tramitadora;

   FUNCTION f_producto(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(2000);
      num_err        NUMBER := 0;
      vcramo         NUMBER;
      vdescrip       VARCHAR2(100);
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := f_desproducto(vcramo, vcmodali, 2, pcidioma, vdescrip, vctipseg, vccolect);

      IF num_err = 0 THEN
         resultado := UPPER(vdescrip);
      ELSE
         resultado := NULL;
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_producto;

   FUNCTION f_falta(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(30);
   BEGIN
      SELECT TO_CHAR(fmovimi, 'dd/mm/yyyy')
        INTO resultado
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi = 1;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_falta;

   FUNCTION f_solicitud_reempl(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_sreempl      reemplazos.sreempl%TYPE;
      resultado      VARCHAR2(30);
      v_nreemp       NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_nreemp
        FROM reemplazos
       WHERE sseguro = psseguro;

      IF v_nreemp > 1 THEN
         SELECT sreempl
           INTO v_sreempl
           FROM reemplazos r
          WHERE r.sseguro = psseguro
            AND r.fmovdia = (SELECT MAX(fmovdia)
                               FROM reemplazos
                              WHERE sseguro = psseguro
                                AND cusuario = r.cusuario
                                AND sreempl = r.sreempl
                                AND cagente = r.cagente);
      ELSE
         SELECT sreempl
           INTO v_sreempl
           FROM reemplazos
          WHERE sseguro = psseguro;
      END IF;

      BEGIN
         SELECT nsolici
           INTO resultado
           FROM seguros
          WHERE sseguro = v_sreempl;
      EXCEPTION
         WHEN OTHERS THEN
            resultado := 'XXXXXXXXX';
      END;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_solicitud_reempl;

   FUNCTION f_fefecto(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fefecto, 'DD/MM/YYYY')
        INTO resultado
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fefecto;

   FUNCTION f_fcancel(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(10);
   BEGIN
      SELECT TO_CHAR(fcancel, 'DD/MM/YYYY')
        INTO resultado
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fcancel;

   -- BUG 0018967 - 07/09/2011 - JMF
   PROCEDURE p_log_correo(
      pevento IN DATE,
      pmrecep IN VARCHAR2,
      pusuari IN VARCHAR2,
      pasunto IN VARCHAR2,
      pterror IN VARCHAR2,
      poficin IN VARCHAR2,
      ptermin IN VARCHAR2) AS
      /* - procedimiento que guarda logs relacionados con el correo */
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO log_correo
                  (seqlogcorreo, fevento, cmailrecep,
                   cusuenvio, asunto, error,
                   coficina, cterm)
           VALUES (seqlogcorreo.NEXTVAL, pevento, SUBSTR(pmrecep, 1, 100),
                   SUBSTR(pusuari, 1, 20), SUBSTR(pasunto, 1, 250), SUBSTR(pterror, 1, 1000),
                   SUBSTR(poficin, 1, 10), SUBSTR(ptermin, 1, 10));

      COMMIT;
   END p_log_correo;

   -- 5. 0022753: MDP_A001-Cierre de remesa - Inicio
   /*******************************************************************************
   FUNCION f_reemplaza_valores
   Función que reemplaza los valores de los parámetros que se puedan incluir en
   el texto del asunto o del cuerpo del mail.El número de parámetros es ilimitado

   Ejemplo:  '
   psubject := 'A fecha #1# la remesa #2# ha quedado en estado #3#';
   ptcuerpo := '12/12/2012|1559|CERRADO';
   retorna     'A fecha 12/12/2012 la remesa 1559 ha quedado en estado CERRADO'

   Parámetros:
    Entrada :
       psubject
       ptcuerpo

   Retorna: texto modificado.
   ********************************************************************************/
   FUNCTION f_reemplaza_valores(psubject VARCHAR2, ptcuerpo VARCHAR2)
      RETURN VARCHAR2 IS
      var1           VARCHAR2(9000) := psubject;
      par1           VARCHAR2(9000) := ptcuerpo;
      vnum           NUMBER := 1;
      vn1            NUMBER;
      vnparam        NUMBER;
   BEGIN
      vnparam := LENGTH(par1) - LENGTH(REPLACE(par1, '|', '')) + 1;

      WHILE(vnum <= vnparam) LOOP
         vn1 := INSTR(par1, '|');

         IF vn1 = 0 THEN
            vn1 := LENGTH(par1) + 1;
         END IF;

         var1 := REPLACE(var1, '#' || vnum || '#', SUBSTR(par1, 0, vn1 - 1));
         vnum := vnum + 1;
         par1 := SUBSTR(par1, vn1 + 1);
      END LOOP;

      RETURN var1;
   END f_reemplaza_valores;

-- 5. 0022753: MDP_A001-Cierre de remesa - Fin
-- BUG: 25910  AMJ   05/02/2013   0025910: LCOL: Enviament de correu en el proc?s de liquidaci?   Ini
   /****************************************************************************************
   Funcion que nos devuelve todos los parametros necesarios para informar por correo que el
   proceso ha finalizado.

   RETURN               : 0-ok : 1-error
   *******************************************************************************************/
   FUNCTION f_envia_correo(
      pvidioma IN NUMBER,
      psproliq IN NUMBER,
      pctipo IN NUMBER DEFAULT 13,
      ptexto IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      v_subject      desmensaje_correo.asunto%TYPE;
      v_from         mensajes_correo.remitente%TYPE;
      v_to           VARCHAR2(250);
      v_to2          VARCHAR2(250);
      v_texto        desmensaje_correo.cuerpo%TYPE;
      ptxtaux        VARCHAR2(250);
      v_errcor       VARCHAR2(1000);
      pscorreo       mensajes_correo.scorreo%TYPE;
      v_pasexec      NUMBER(8);
      v_param        VARCHAR2(200)
         := 'params : pvidioma : ' || pvidioma || '; psproliq : ' || psproliq || '; pctipo : '
            || pctipo || '; ptexto : ' || ptexto;
      v_object       VARCHAR2(200) := 'PAC_Correo.f_envia_correo';
      v_error        VARCHAR2(200);
   BEGIN
      -- obtenemos el scorreo
      BEGIN
         SELECT MAX(scorreo)
           INTO pscorreo
           FROM mensajes_correo
          WHERE ctipo = pctipo;   -- Tipo correo fin de proceso
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END;

      -- Obtenemos el asunto
      SELECT MAX(asunto)
        INTO v_subject
        FROM desmensaje_correo
       WHERE scorreo = pscorreo
         AND cidioma = pvidioma;

      IF v_subject IS NULL THEN
         --No esixte ningún Subject para este tipo de correo.
         RETURN 151422;
      END IF;

      --Obtenemos el origen
      v_pasexec := 1;

      BEGIN
         SELECT MAX(remitente)
           INTO v_from
           FROM mensajes_correo
          WHERE scorreo = pscorreo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151425;   --No existe ningún correo de este tipo .
      END;

      --Obtenemos los detinatarios
      v_pasexec := 2;

      DECLARE
         CURSOR c1 IS
            SELECT destinatario, descripcion, direccion
              FROM destinatarios_correo
             WHERE scorreo = pscorreo;
      BEGIN
         v_pasexec := 3;
         v_to := NULL;
         v_to2 := NULL;
         v_pasexec := 4;

         FOR f1 IN c1 LOOP
            v_pasexec := 5;
            v_to := RTRIM(f1.direccion || ';' || v_to, ';');
            v_pasexec := 6;
            v_to2 := RTRIM(f1.descripcion || ';' || v_to2, ';');
         END LOOP;

         v_pasexec := 7;

         IF v_to IS NULL THEN
            RETURN 151423;   -- No se han encontrado destinatarios de correo
         END IF;
      END;

      -- Obtenemos el cuerpo del correo
      v_pasexec := 8;

      SELECT MAX(cuerpo)
        INTO v_texto
        FROM desmensaje_correo
       WHERE scorreo = pscorreo
         AND cidioma = pvidioma;

      IF v_texto IS NULL THEN
         --No esixte ningún Subject para este tipo de correo.
         RETURN 151422;
      END IF;

      -- CASOS PARTICULARES
      v_pasexec := 9;

      -- Bug 26209  FAC - INI 27/02/2013 - Solución definitiva ejecución de cartera desde pantalla
      IF ptexto IS NOT NULL THEN
         v_texto := v_texto || CHR(10) || ptexto;
      END IF;

      -- Bug 26209  FAC - FIN 27/02/2013 - Solución definitiva ejecución de cartera desde pantalla

      -- Bug 26777 - APD - 25/04/2013
      IF psproliq IS NOT NULL THEN
         v_texto := v_texto || '-' || psproliq;
      END IF;

      -- fin Bug 26777 - APD - 25/04/2013
      BEGIN
         -- Enviar el correo
         v_pasexec := 10;
         -- Bug 26777 - APD - 25/04/2013 - se sustituye v_texto || '-' || psproliq por v_texto
         p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);
         v_errcor := '0';
         --Bug 27520/147846 - 28/06/2013 - AMC
         p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
         --Fi Bug 27520/147846 - 28/06/2013 - AMC
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            v_errcor := SQLCODE || ' ' || SQLERRM || CHR(10) || 'pscorreo=' || pscorreo
                        || ' to=' || v_to || ' ' || v_subject;
            --Bug 27520/147846 - 28/06/2013 - AMC
            p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
            --Fi Bug 27520/147846 - 28/06/2013 - AMC
            RETURN 1;
      END;

      v_pasexec := 11;
   EXCEPTION
      WHEN OTHERS THEN
         v_errcor := SQLCODE || ' ' || SQLERRM || CHR(10) || 'pscorreo=' || pscorreo || ' to='
                     || v_to || ' ' || v_subject;
         --Bug 27520/147846 - 28/06/2013 - AMC
         p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
         --Fi Bug 27520/147846 - 28/06/2013 - AMC
         RETURN 1;
   END f_envia_correo;

-- -- BUG: 25910  AMJ   04/02/2013   0025910: LCOL: Enviament de correu en el proc?s de liquidaci?   Fi
/****************************************************************************************
   Funcion que nos devuelve todos los parametros necesarios para informar por correo que el
   proceso ha finalizado.

   RETURN               : 0-ok : 1-error
   *******************************************************************************************/
   FUNCTION f_envia_correo_agentes(
      pcagente IN NUMBER,
      pvidioma IN NUMBER,
      pscorreo IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pdirectorio IN VARCHAR2,
      pfichero IN VARCHAR2,
      pctipo IN NUMBER DEFAULT 17,
      ptexto IN VARCHAR2 DEFAULT NULL,
      pdirectorio2 IN VARCHAR2 DEFAULT 'GEDOXTEMPORAL',
      pfichero2 IN VARCHAR2 DEFAULT NULL,
      ptoccc IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      v_subject      desmensaje_correo.asunto%TYPE;
      v_from         mensajes_correo.remitente%TYPE;
      v_to           VARCHAR2(400);
      v_to2          VARCHAR2(250);
      v_texto        desmensaje_correo.cuerpo%TYPE;
      ptxtaux        VARCHAR2(250);
      v_errcor       VARCHAR2(1000);
      --pscorreo       mensajes_correo.scorreo%TYPE;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'params : pvidioma : ' || pvidioma || '; pctipo : ' || pctipo || '; ptexto : '
            || ptexto;
      v_object       VARCHAR2(200) := 'PAC_Correo.f_envia_correo_agentes';
      v_error        VARCHAR2(200);
      pos            NUMBER;
      --v_directorio   VARCHAR2(50) := 'GEDOXTEMPORAL';
      v_tocc         VARCHAR2(50);
      v_toccc        VARCHAR2(50);
      v_nomage       VARCHAR2(100);
   BEGIN
      -- Obtenemos el asunto
      SELECT MAX(asunto)
        INTO v_subject
        FROM desmensaje_correo
       WHERE scorreo = pscorreo
         AND cidioma = pvidioma;

      IF v_subject IS NULL THEN
         --No esixte ningún Subject para este tipo de correo.
         RETURN 151422;
      END IF;

      v_toccc := ptoccc;
      --Obtenemos el origen
      v_pasexec := 2;

      BEGIN
         SELECT MAX(remitente)
           INTO v_from
           FROM mensajes_correo
          WHERE scorreo = pscorreo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151425;   --No existe ningún correo de este tipo .
      END;

      --Obtenemos los detinatarios
      v_pasexec := 3;

      BEGIN
         SELECT tcorreo
           INTO v_to
           FROM agentes_correo
          WHERE scorreo = pscorreo
            AND cagente = pcagente;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151425;   --No existe ningún correo de este tipo .
      END;

      v_pasexec := 4;

      IF v_to IS NULL THEN
         BEGIN
            SELECT tcorreo
              INTO v_to
              FROM agentes_comp
             WHERE cagente = pcagente;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 151425;   --No existe ningún correo de este tipo .
         END;
      END IF;

      v_pasexec := 5;

      IF v_to IS NULL THEN
         --no hay correo donde enviar
         RETURN 151423;
      END IF;

      v_pasexec := 6;

      SELECT f_nombre(sperson, 1, NULL)
        INTO v_nomage
        FROM agentes
       WHERE cagente = pcagente;

      -- Obtenemos el cuerpo del correo
      v_pasexec := 8;

      SELECT MAX(cuerpo)
        INTO v_texto
        FROM desmensaje_correo
       WHERE scorreo = pscorreo
         AND cidioma = pvidioma;

      IF v_texto IS NULL THEN
         --No esixte ningún Subject para este tipo de correo.
         RETURN 151422;
      END IF;

      --reemplazamos
      pos := INSTR(v_subject, '#YYYY.MM#', 1);

      IF pos > 0 THEN
         v_subject := REPLACE(v_subject, '#YYYY.MM#', TO_CHAR(pfini, 'YYYY.MM'));
      END IF;

      pos := INSTR(v_subject, '#CAGENTE#', 1);

      IF pos > 0 THEN
         v_subject := REPLACE(v_subject, '#CAGENTE#', pcagente);
      END IF;

      pos := INSTR(v_texto, '#REMITENTE#', 1);

      IF pos > 0 THEN
         v_texto := REPLACE(v_texto, '#REMITENTE#', v_from);
      END IF;

      pos := INSTR(v_texto, '#NOMBREAGENTE#', 1);

      IF pos > 0 THEN
         v_texto := REPLACE(v_texto, '#NOMBREAGENTE#', v_nomage);
      END IF;

      pos := INSTR(v_texto, '#CAGENTE#', 1);
      IF pos > 0 THEN
         v_texto := REPLACE(v_texto, '#CAGENTE#', pcagente);
      END IF;

      BEGIN
         SELECT tcorreo
           INTO v_tocc
           FROM agentes_comp
          WHERE cagente = pac_redcomercial.f_busca_padre(f_parinstalacion_n('EMPRESADEF'),
                                                         pcagente, 3, f_sysdate)
            AND cenvcorreo = 1;
      EXCEPTION
         WHEN OTHERS THEN
            v_tocc := NULL;
      END;

      -- CASOS PARTICULARES
      v_pasexec := 9;

      IF ptexto IS NOT NULL THEN
         v_texto := v_texto || CHR(10) || ptexto;
      END IF;

      BEGIN
         -- Enviar el correo
         v_pasexec := 10;
         --p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);
         v_errcor := pac_md_informes.f_enviar_mail(NULL, v_to, pdirectorio, pfichero,
                                                   v_subject, v_texto, v_tocc, v_toccc,
                                                   pdirectorio, v_from, pdirectorio2,
                                                   pfichero2);
         --v_errcor := '0';
         --Bug 27520/147846 - 28/06/2013 - AMC
         p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
         --Fi Bug 27520/147846 - 28/06/2013 - AMC
         RETURN v_errcor;
      EXCEPTION
         WHEN OTHERS THEN
            v_errcor := SQLCODE || ' ' || SQLERRM || CHR(10) || 'pscorreo=' || pscorreo
                        || ' to=' || v_to || ' ' || v_subject;
            --Bug 27520/147846 - 28/06/2013 - AMC
            p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
            --Fi Bug 27520/147846 - 28/06/2013 - AMC
            RETURN 1;
      END;

      v_pasexec := 11;
   EXCEPTION
      WHEN OTHERS THEN
         v_errcor := SQLCODE || ' ' || SQLERRM || CHR(10) || 'pscorreo=' || pscorreo || ' to='
                     || v_to || ' ' || v_subject;
         --Bug 27520/147846 - 28/06/2013 - AMC
         p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
         --Fi Bug 27520/147846 - 28/06/2013 - AMC
         RETURN 1;
   END f_envia_correo_agentes;
--   FUNCTION f_envia_correo_listado_agentes(
--      pscorreo IN NUMBER,
--      pfenvio IN DATE,
--      pfinicio IN DATE,
--      pfinal IN DATE,
--      pcorreoresumen IN VARCHAR2,
--      pdirectorio IN VARCHAR DEFAULT 'GEDOXTEMPORAL',
--      pcagente IN NUMBER DEFAULT NULL)
--      RETURN NUMBER IS
--      numer          NUMBER;
--      v_scorreo      NUMBER := pscorreo;
--      v_titulo       VARCHAR2(100);
--      v_cidioma      NUMBER := 2;
--      psproces       NUMBER;
--      vnprolin       NUMBER;
--      pfini          VARCHAR2(20);
--      pfin           VARCHAR2(20);
--      vcoun          NUMBER;
--      mensajes       t_iax_mensajes := t_iax_mensajes();
--      pparams        t_iax_info := t_iax_info();
--      params         ob_iax_info := ob_iax_info();
--      pnomfich       VARCHAR2(500);
--      pofich         VARCHAR2(500);
--      vdirectorio2   VARCHAR2(20) := pdirectorio;
--      vfichero2      VARCHAR2(100) := '#CODIGOAGENTE#_RECIBO_CARTERA_#YYYYMM#.PDF';
--      v_to           VARCHAR2(100);
--      v_toresumen    VARCHAR2(100) := pcorreoresumen;
--      v_error        VARCHAR2(100);
--      v_texto        VARCHAR2(2000);
--      vok            NUMBER := 0;
--      vko            NUMBER := 0;
--      vpasexec       NUMBER := 1;
--      vobject        VARCHAR2(200) := 'PAC_CORREO.f_envia_correo_listado_agentes';
--      v_subject      VARCHAR2(200);
--      pos            NUMBER := 0;
--      v_adjunto2     VARCHAR2(50);

--      CURSOR c_agentes IS
--         SELECT ac.cagente
--           FROM agentes_correo ac, agentes_comp ap
--          WHERE ac.scorreo = v_scorreo
--            AND ac.cagente = ap.cagente
--            AND ap.cenvcorreo = 1
--            AND ac.cenviar = 1
--            AND(ac.tcorreo IS NOT NULL
--                OR ap.tcorreo IS NOT NULL)
--            AND(ac.cagente = pcagente
--                OR pcagente IS NULL);
--   BEGIN
--      BEGIN
--         numer :=
--            pac_contexto.f_inicializarctx(f_parempresa_t('USER_BBDD',
--                                                         f_parinstalacion_n('EMPRESADEF')));

--         SELECT tatribu
--           INTO v_titulo
--           FROM detvalores
--          WHERE cvalor = 714
--            AND catribu = v_scorreo
--            AND cidioma = v_cidioma;
--      EXCEPTION
--         WHEN OTHERS THEN
--            p_tab_error(f_sysdate, f_user, vobject, vpasexec, SQLCODE, SQLERRM);
--      END;

--      vpasexec := 2;
--      numer := f_procesini(f_parempresa_t('USER_BBDD', f_parinstalacion_n('EMPRESADEF')),
--                           f_parinstalacion_n('EMPRESADEF'), 'ENVIO_CORREO_AGENTE', v_titulo,
--                           psproces);

--      /*SELECT '01' || TO_CHAR(f_sysdate - 1, 'mmrrrr'),
--             TO_CHAR(LAST_DAY(f_sysdate - 1), 'ddmmrrrr')
--        INTO pfini,
--             pfin
--        FROM DUAL;*/
--      IF v_scorreo = 303 THEN
--         SELECT tatribu
--           INTO v_adjunto2
--           FROM detvalores
--          WHERE cvalor = 1904
--            AND catribu = 29
--            AND cidioma = v_cidioma;

--         vfichero2 := '#CODIGOAGENTE#_' || v_adjunto2 || '_#YYYYMM#.PDF';
--         pfini := '01' || TO_CHAR(pfinicio, 'mmrrrr');
--         pfin := TO_CHAR(LAST_DAY(pfinal), 'ddmmrrrr');
--         vpasexec := 3;

----recorremos agentes a los que se les pueda enviar el correo
--         FOR c IN c_agentes LOOP
----miramos si genera el listado
--            SELECT COUNT(1)
--              INTO vcoun
--              FROM seguros se, recibos r, vdetrecibos det
--             WHERE se.sseguro = r.sseguro
--               AND r.nrecibo = det.nrecibo
--               AND r.ctiprec = 3   --recibo cartera
--               AND(r.cagente, r.cempres) IN(
--                     SELECT rc.cagente, rc.cempres
--                       FROM (SELECT     rc.cagente, rc.cempres
--                                   FROM redcomercial rc
--                                  WHERE rc.fmovfin IS NULL
--                             START WITH rc.cagente =
--                                           NVL
--                                              (c.cagente,
--                                               ff_agente_cpolvisio
--                                                               (pac_user.ff_get_cagente(f_user)))
--                             CONNECT BY PRIOR rc.cagente = rc.cpadre
--                                    AND PRIOR rc.fmovfin IS NULL) rc)
--               AND r.fefecto BETWEEN NVL(TO_DATE(LTRIM(TO_CHAR(pfini, '09999999')), 'ddmmrrrr'),
--                                         r.fefecto)
--                                 AND NVL(TO_DATE(LTRIM(TO_CHAR(pfin, '09999999')), 'ddmmrrrr'),
--                                         r.fefecto);

--            vpasexec := 4;

--            IF vcoun > 0 THEN
----listado:
----parametros
--               pparams.EXTEND;
--               params.nombre_columna := 'PCAGENTE';
--               params.valor_columna := c.cagente;
--               params.tipo_columna := 1;
--               pparams(pparams.LAST) := params;
--               pparams.EXTEND;
--               params.nombre_columna := 'PFINI';
--               params.valor_columna := pfini;
--               params.tipo_columna := 1;
--               pparams(pparams.LAST) := params;
--               pparams.EXTEND;
--               params.nombre_columna := 'PFIN';
--               params.valor_columna := pfin;
--               params.tipo_columna := 1;
--               pparams(pparams.LAST) := params;
--               numer := pac_iax_informes.f_ejecuta_informe('PRBLIST003',
--                                                           f_parinstalacion_n('EMPRESADEF'),
--                                                           'CSV', pparams, 2, 0, NULL,
--                                                           pnomfich, pofich, mensajes);
--               vpasexec := 5;
--               --si hay listado enviamos
--               vfichero2 := REPLACE(vfichero2, '#CODIGOAGENTE#', c.cagente);
--               vfichero2 := REPLACE(vfichero2, '#YYYYMM#', TO_CHAR(pfenvio, 'YYYYMM'));
--               numer := pac_correo.f_envia_correo_agentes(c.cagente, v_cidioma, v_scorreo,
--                                                          pfini, pfin, pnomfich, 17, NULL,
--                                                          vdirectorio2, vfichero2
--                                                                                 --null
--                       );
--               vpasexec := 6;

--               BEGIN
--                  SELECT tcorreo
--                    INTO v_to
--                    FROM agentes_correo
--                   WHERE scorreo = v_scorreo
--                     AND cagente = c.cagente;
--               EXCEPTION
--                  WHEN OTHERS THEN
--                     v_to := NULL;   --No existe ningún correo de este tipo .
--               END;

--               vpasexec := 7;

--               IF v_to IS NULL THEN
--                  BEGIN
--                     SELECT tcorreo
--                       INTO v_to
--                       FROM agentes_comp
--                      WHERE cagente = c.cagente;
--                  EXCEPTION
--                     WHEN OTHERS THEN
--                        v_error := 'no se ha podido encontrar la dirección de correo';   --No existe ningún correo de este tipo .
--                  END;
--               END IF;

--               vpasexec := 8;

--               IF v_to IS NULL THEN
--                  v_to := 'no se ha encontrado dirección de correo';
--               END IF;

--               IF numer <> 0 THEN
--                  vpasexec := 9;

--                  INSERT INTO agentes_correo_env
--                              (scorreo, cagente, sproces, fenvio, tdocumento, tcorreo,
--                               cestado, terror)
--                       VALUES (v_scorreo, c.cagente, psproces, pfenvio, pnomfich, v_to,
--                               2, v_error || f_axis_literales(numer, v_cidioma));

--                  vko := vko + 1;
--                  numer := f_proceslin(psproces,
--                                       numer || ' - ' || f_axis_literales(numer, v_cidioma),
--                                       c.cagente, vnprolin, 1);
--               ELSE
--                  vpasexec := 10;

--                  INSERT INTO agentes_correo_env
--                              (scorreo, cagente, sproces, fenvio, tdocumento, tcorreo,
--                               cestado, terror)
--                       VALUES (v_scorreo, c.cagente, psproces, pfenvio, pnomfich, v_to,
--                               1, f_axis_literales(numer, v_cidioma));

--                  vok := vok + 1;
--                  numer := f_proceslin(psproces,
--                                       numer || ' - ' || f_axis_literales(numer, v_cidioma),
--                                       c.cagente, vnprolin, NULL);
--               END IF;
--            END IF;
--         END LOOP;
--      END IF;

--      COMMIT;
--      vpasexec := 11;

--      /*
--      v_texto := 'El proceso de ' || v_titulo || ' ha enviado correctamente ' || vok
--                 || ' correos y ' || vko || ' erróneos. Revisar el proceso ' || psproces
--                 || ' o la tabla agentes_correo_env para más información.';
--      numer := pac_md_informes.f_enviar_mail(NULL, v_toresumen, NULL, NULL,
--                                             'Resumen envío proceso ' || psproces, v_texto);*/

--      --Resumen
---- Obtenemos el asunto
--      SELECT MAX(asunto)
--        INTO v_subject
--        FROM desmensaje_correo
--       WHERE scorreo = 300
--         AND cidioma = v_cidioma;

--      IF v_subject IS NULL THEN
--         --No esixte ningún Subject para este tipo de correo.
--         RETURN 151422;
--      END IF;

--      SELECT MAX(cuerpo)
--        INTO v_texto
--        FROM desmensaje_correo
--       WHERE scorreo = 300
--         AND cidioma = v_cidioma;

--      IF v_texto IS NULL THEN
--         --No esixte ningún Subject para este tipo de correo.
--         RETURN 151422;
--      END IF;

--      --reemplazamos
--      pos := INSTR(v_subject, '#SPROCES#', 1);

--      IF pos > 0 THEN
--         v_subject := REPLACE(v_subject, '#SPROCES#', psproces);
--      END IF;

--      pos := INSTR(v_subject, '#OK#', 1);

--      IF pos > 0 THEN
--         v_subject := REPLACE(v_subject, '#OK#', vok);
--      END IF;

--      pos := INSTR(v_subject, '#KO#', 1);

--      IF pos > 0 THEN
--         v_subject := REPLACE(v_subject, '#KO#', vko);
--      END IF;

--      pos := INSTR(v_texto, '#TITULO#', 1);

--      IF pos > 0 THEN
--         v_texto := REPLACE(v_texto, '#TITULO#', v_titulo);
--      END IF;

--      pos := INSTR(v_texto, '#SPROCES#', 1);

--      IF pos > 0 THEN
--         v_texto := REPLACE(v_texto, '#SPROCES#', psproces);
--      END IF;

--      pos := INSTR(v_texto, '#OK#', 1);

--      IF pos > 0 THEN
--         v_texto := REPLACE(v_texto, '#OK#', vok);
--      END IF;

--      pos := INSTR(v_texto, '#KO#', 1);

--      IF pos > 0 THEN
--         v_texto := REPLACE(v_texto, '#KO#', vko);
--      END IF;

--      numer := pac_md_informes.f_enviar_mail(NULL, v_toresumen, NULL, NULL, v_subject, v_texto);
--      vpasexec := 12;
--      numer := f_procesfin(psproces, vko);
--      RETURN numer;
--   EXCEPTION
--      WHEN OTHERS THEN
--         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
--                     pnomfich || ' -p ' || pofich || ' -n ' || numer, SQLERRM);
--         RETURN numer;
--   END f_envia_correo_listado_agentes;
  FUNCTION f_tomador(
          psseguro  IN NUMBER)
        RETURN VARCHAR2 IS

    CURSOR c_tomadores IS
      SELECT SPERSON FROM TOMADORES
        WHERE SSEGURO = psseguro;
    r_tomador    NUMBER;
    pnombre      VARCHAR2(500);
    v_errcor     VARCHAR2(1000);
    vobject      VARCHAR(100) := 'pac_correo.f_tomador';
    vpasexec     NUMBER;
  BEGIN
    vpasexec := 1;
    OPEN c_tomadores;
      FETCH c_tomadores INTO r_tomador;

      pnombre := F_NOMBRE(PSPERSON => r_tomador,
                      PNFORMAT => 2,
                      PCAGENTE => NULL);


    CLOSE   c_tomadores;

    RETURN pnombre;
  EXCEPTION
      WHEN OTHERS THEN
         v_errcor := SQLCODE || ' ' || SQLERRM ;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     pnombre, SQLERRM);

         RETURN '9000735';
  END f_tomador;


  FUNCTION f_estadopol(
          psseguro  IN NUMBER)
        RETURN VARCHAR2 IS

    CURSOR c_estado IS
      SELECT
        (SELECT T.TMOTMOV FROM MOTMOVSEG T WHERE T.CMOTMOV = M.CMOTMOV AND CIDIOMA = 8 ) TMOTMOV
      FROM  MOVSEGURO M
        WHERE SSEGURO = psseguro
        AND   NMOVIMI = (SELECT NMOVIMI FROM  MOVSEGURO   WHERE SSEGURO = psseguro);

    r_estado     VARCHAR2(500);
    v_errcor     VARCHAR2(1000);
    vobject      VARCHAR(100) := 'pac_correo.f_estadopol';
    vpasexec     NUMBER;

  BEGIN
    vpasexec := 1;
    OPEN c_estado;
      FETCH c_estado  INTO r_estado;

    CLOSE   c_estado;

    RETURN r_estado;
  EXCEPTION
      WHEN OTHERS THEN
         v_errcor := SQLCODE || ' ' || SQLERRM ;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     r_estado, SQLERRM);

         RETURN '104349';
  END f_estadopol;

  FUNCTION f_usuariopol(
          psseguro  IN NUMBER)
        RETURN VARCHAR2 IS

    CURSOR c_estado IS
      SELECT
        CUSUMOV
      FROM  MOVSEGURO M
        WHERE SSEGURO = psseguro
        AND   NMOVIMI = (SELECT NMOVIMI FROM  MOVSEGURO   WHERE SSEGURO = psseguro);

    r_usuario     VARCHAR2(500);
    v_errcor     VARCHAR2(1000);
    vobject      VARCHAR(100) := 'pac_correo.f_usuariopol';
    vpasexec     NUMBER;

  BEGIN
    vpasexec := 1;
    OPEN c_estado;
      FETCH c_estado  INTO r_usuario;

    CLOSE   c_estado;

    RETURN r_usuario;
  EXCEPTION
      WHEN OTHERS THEN
         v_errcor := SQLCODE || ' ' || SQLERRM ;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     r_usuario, SQLERRM);

         RETURN '104349';
  END f_usuariopol;

   FUNCTION f_sistema
      RETURN VARCHAR2 IS
      resultado      VARCHAR2(30);
   BEGIN
      SELECT TO_CHAR(f_sysdate, 'dd/mm/yyyy')
        INTO resultado
        FROM dual;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_sistema;

  FUNCTION f_origen_tarea(pnsinies  IN NUMBER,
                          pntramit  IN NUMBER,
                          pidapunte IN NUMBER) RETURN VARCHAR2 IS
     resultado VARCHAR2(20);
  BEGIN

     SELECT u.tusunom
       INTO resultado
       FROM agd_agenda a,
            agd_apunte p,
            usuarios u
      WHERE a.tclagd = pnsinies
        AND a.ntramit = pntramit
        AND a.idapunte = pidapunte
        AND a.idapunte = p.idapunte
        AND p.cusualt = u.cusuari;

     RETURN resultado;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL;
  END f_origen_tarea;

  FUNCTION f_descripcion_tarea(pidapunte IN NUMBER) RETURN VARCHAR2 IS
     resultado VARCHAR2(2000);
  BEGIN

     SELECT p.tapunte
       INTO resultado
       FROM agd_apunte p
      WHERE p.idapunte = pidapunte;

     RETURN resultado;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL;
  END f_descripcion_tarea;

PROCEDURE P_CAMBIO_REGIMEN (P_CAGENTE IN NUMBER) IS

X_NOMBREAGENTE VARCHAR2(1000) ;
X_IDAGENTE NUMBER(14) ;
X_TEXTO_EMAIL VARCHAR2(1000):= 'Sr(s). :NOMBRE_AGENTE:, Identificad@  con :ID_AGENTE:,
Nos permitimos informar que debe realizar el cambio de régimen simplificado a régimen común ante la DIAN, mediante la actualización del Registro Único Tributario (RUT); Por cumplir con el tope máximo de ingreso generados; Lo más recomendable es hacerlo de manera voluntaria, y no esperar a que la DIAN se percate de la situación y emita resolución exigiendo el cambio de régimen.';
X_MAIL_AGENTE VARCHAR2(300);
X_MAIL_SUCURSAL VARCHAR2(300);
X_MAIL_COMERCIAL VARCHAR2(300) := 'hscanabria@confianza.com.co';
X_MAIL_CARTERA VARCHAR2(300) := 'csuarez@confianza.com.co';
X_MAIL_SUSCRIPTOR VARCHAR2(300);

v_from         VARCHAR2(250);
v_to           VARCHAR2(250);
v_to2          VARCHAR2(250);
v_errcor       VARCHAR2(1000);


BEGIN
/*BUSCAR CORREO AGENTE EN AGENTES_COMP*/
BEGIN
SELECT nvl(A.TCORREO , 'hsanabria@confianza.com.co' )
INTO X_MAIL_AGENTE
FROM AGENTES_COMP A WHERE A.CAGENTE = P_CAGENTE;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    X_MAIL_AGENTE := '';
END;


/*BUSCAR CORREO DEL PADRE DEL AGENTE EN AGENTES_COMP*/
BEGIN
SELECT nvl(A.TCORREO, 'hsanabria@confianza.com.co' )
INTO X_MAIL_SUCURSAL
FROM AGENTES_COMP A WHERE A.CAGENTE = (SELECT CPADRE FROM REDCOMERCIAL
WHERE CAGENTE = P_CAGENTE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
    X_MAIL_SUCURSAL := '';
END;


/*BUSCAR CORREO DEL SUSCRIPTOR */
BEGIN
SELECT NVL(A.MAIL_USU, 'hsanabria@confianza.com.co' )
INTO X_MAIL_SUSCRIPTOR
FROM USUARIOS A WHERE A.CUSUARI = F_USER;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    X_MAIL_SUSCRIPTOR := '';
END;

/*BUSCAR NOMBRE E IDENTIFICACION DEL AGENTE */
BEGIN
SELECT f_nombre(A.SPERSON, 4, ''), (SELECT (CASE WHEN CTIPIDE = '37' THEN SUBSTR(B.NNUMIDE, 1, LENGTH(B.NNUMIDE)-1) ELSE B.NNUMIDE END) FROM PER_PERSONAS B WHERE B.SPERSON = A.SPERSON)
INTO X_NOMBREAGENTE, X_IDAGENTE
FROM AGENTES A WHERE A.CAGENTE = P_CAGENTE;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    X_NOMBREAGENTE := '';
    X_IDAGENTE := '';
END;

/* Ajuste Texto del cuerpo del correo*/
X_TEXTO_EMAIL := REPLACE(REPLACE (X_TEXTO_EMAIL, ':NOMBRE_AGENTE:', X_NOMBREAGENTE), ':ID_AGENTE:', X_IDAGENTE);

/* Envío del correo */
v_from := 'no-reply@confianza.com.co';
v_to := RTRIM( X_MAIL_AGENTE|| ';' || X_MAIL_SUCURSAL ||';'||X_MAIL_COMERCIAL||';'||X_MAIL_CARTERA||';'||X_MAIL_SUSCRIPTOR, ';');
v_to2 := RTRIM( 'AGENTE;SUCURSAL;COMERCIAL;CARTERA;SUCRIPTOR', ';');

p_enviar_correo(v_from, v_to, v_from, v_to2, 'ALERTA PSU CAMBIO DE REGIMEN', X_TEXTO_EMAIL);

PAC_CORREO.p_log_correo(f_sysdate, v_to, f_user, 'ALERTA PSU CAMBIO DE REGIMEN', 0, NULL, NULL);


EXCEPTION
WHEN OTHERS THEN
            v_errcor := SQLCODE || ' ' || SQLERRM || CHR(10) || 'AGENTE =' || P_CAGENTE
                        || ' to=' || v_to || ' ' || 'ALERTA PSU CAMBIO DE REGIMEN';
            --Bug 27520/147846 - 28/06/2013 - AMC
            PAC_CORREO.p_log_correo(f_sysdate, v_to, f_user, 'ALERTA PSU CAMBIO DE REGIMEN', v_errcor, NULL, NULL);


END P_CAMBIO_REGIMEN;
-- INI IAXIS-3363 - JLTS - 28/03/2019
	FUNCTION f_data_rd(psrdian IN rango_dian.srdian%TYPE, pncampo IN NUMBER) RETURN VARCHAR2 IS
		v_retorno VARCHAR2(2000) := NULL;

		CURSOR c1 IS
			SELECT r.*
				FROM rango_dian r
			 WHERE r.srdian = psrdian;
		c1_r c1%ROWTYPE;
	BEGIN
		OPEN c1;
		FETCH c1
			INTO c1_r;
		CLOSE c1;
		IF pncampo = 1 THEN
			RETURN c1_r.cagente;
		ELSIF pncampo = 2 THEN
			RETURN c1_r.sproduc;
		ELSIF pncampo = 3 THEN
			RETURN c1_r.nresol;
		ELSIF pncampo = 4 THEN
			RETURN to_char(c1_r.fresol, 'DD/MM/YYYY');
		END IF;
	END f_data_rd;
-- FIN IAXIS-3363 - JLTS - 28/03/2019
END pac_correo;
/
