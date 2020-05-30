--------------------------------------------------------
--  DDL for Package Body PAC_XML_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_XML_MV" AS
-------------------------------------------------------------
   PROCEDURE p_inicializar_sinterf IS
   BEGIN
      SELECT sinterf.NEXTVAL
        INTO pac_xml_mv.vsinterf
        FROM DUAL;
   END;

   FUNCTION f_obtener_sinterf
      RETURN NUMBER IS
   BEGIN
      RETURN(pac_xml_mv.vsinterf);
   END;

-------------------------------------------------------------
-- Buscar el valor del texto del primer nodo con tag p_tag
-------------------------------------------------------------
   FUNCTION buscarnodotexto(p_doc xmldom.domdocument, p_tag IN VARCHAR2)
      RETURN VARCHAR2 IS
      nl             xmldom.domnodelist;
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
   BEGIN
      nl := xmldom.getelementsbytagname(p_doc, p_tag);

      IF xmldom.getlength(nl) <> 0 THEN
         mynode := xmldom.item(nl, 0);
         mynode := xmldom.getfirstchild(mynode);

         IF NOT xmldom.isnull(mynode) THEN
            RETURN xmldom.getnodevalue(mynode);
         ELSE
            RETURN NULL;
         END IF;
      ELSE
         RETURN NULL;
      END IF;
   END;

-------------------------------------------------------------
   PROCEDURE anadirnodotexto(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_tag IN VARCHAR2,
      p_texto IN VARCHAR2) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_tag);
      mytextnode := xmldom.createtextnode(p_doc, p_texto);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      mynode := xmldom.appendchild(mynode, xmldom.makenode(mytextnode));
   END;

-------------------------------------------------------------
-- Routina para tratar los posibles errores del host o del servidor
-------------------------------------------------------------
   FUNCTION tratarerror(
      p_doc xmldom.domdocument,
      p_nrosecuencia NUMBER,
      p_terror IN OUT VARCHAR2)
      RETURN NUMBER IS
      --sólo la llaman funciones del pac_xml_mv (sistema interfaz viejo)
      --en el futuro se eliminará
      nl             xmldom.domnodelist;
      v_formato      VARCHAR2(2);
      v_msgout       VARCHAR2(32767);
   BEGIN
      IF f_parinstalacion_n('DEBUG') = 1 THEN
         xmldom.writetobuffer(p_doc, v_msgout);

         INSERT INTO tmp_mv
                     (sinterf, v_res)
              VALUES (pac_xml_mv.vsinterf, v_msgout);
      END IF;

      IF TO_CHAR(p_nrosecuencia) <> buscarnodotexto(p_doc, 'NroMensaje') THEN
         p_terror := 'Error fatal en la sincronización';
         RETURN(151303);
      END IF;

      nl := xmldom.getelementsbytagname(p_doc, 'Error');

      IF xmldom.getlength(nl) <> 0 THEN
         p_terror := 'Error Host: ' || buscarnodotexto(p_doc, 'DenMensaje');
         RETURN(151304);
      END IF;

      nl := xmldom.getelementsbytagname(p_doc, 'error');

      IF xmldom.getlength(nl) <> 0 THEN
         p_terror := 'Error Peticion: ' || buscarnodotexto(p_doc, 'mensaje');
         RETURN(151305);
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'tratarError', 1,
                     'Error incontrolado: ' || pac_xml_mv.vsinterf, SQLERRM);
   END;

-------------------------------------------------------------
   FUNCTION obtener_descripcion(p_tipo_codigo VARCHAR2, p_codigo VARCHAR2)
      RETURN VARCHAR2 IS
      CURSOR c_desc IS
         SELECT descripcion_host
           FROM diccionario_host_bm
          WHERE tipo_codigo = p_tipo_codigo
            AND codigo_host = p_codigo;

      v_desc         c_desc%ROWTYPE;
   BEGIN
      OPEN c_desc;

      FETCH c_desc
       INTO v_desc;

      IF c_desc%FOUND THEN
         CLOSE c_desc;

         RETURN v_desc.descripcion_host;
      END IF;

      CLOSE c_desc;

      RETURN NULL;
   -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
   EXCEPTION
      WHEN OTHERS THEN
         IF c_desc%ISOPEN THEN
            CLOSE c_desc;
         END IF;

         RETURN NULL;
   END obtener_descripcion;

-------------------------------------------------------------
-- Extraer nombre apellido1 apellido2 del la cadena apellido1*apellido2*
------------------------------------------------------------
   PROCEDURE extraer_nombre(
      p_nom IN VARCHAR2,
      p_nombre OUT VARCHAR2,
      p_apellido1 OUT VARCHAR2,
      p_apellido2 OUT VARCHAR2) IS
      p_nomaux       VARCHAR2(150) := p_nom;

      PROCEDURE asignar_nombre(p_nomasig IN OUT VARCHAR2, p_nom IN OUT VARCHAR2) IS
      BEGIN
         IF INSTR(p_nom, '*', 1, 1) < 1 THEN
            p_nomasig := p_nomaux;
            p_nom := NULL;
         ELSE
            p_nomasig := SUBSTR(p_nomaux, 1, INSTR(p_nomaux, '*', 1, 1) - 1);
            p_nom := SUBSTR(p_nom, INSTR(p_nomaux, '*', 1, 1) + 1);
         END IF;
      END;
   BEGIN
      p_nomaux := p_nom;

      IF p_nomaux IS NULL THEN
         p_nombre := NULL;
         p_apellido1 := NULL;
         p_apellido2 := NULL;
      ELSE
         -- Primer caso no hay asteriscos
         IF INSTR(p_nomaux, '*', 1, 1) < 1 THEN
            p_nombre := p_nomaux;
            p_apellido1 := NULL;
            p_apellido2 := NULL;
         ELSE
            -- Buscamos de izquierda drcha apellido1*apelledo2*nombre
            asignar_nombre(p_apellido1, p_nomaux);
            asignar_nombre(p_apellido2, p_nomaux);
            asignar_nombre(p_nombre, p_nomaux);
         END IF;
      END IF;
   END;

-------------------------------------------------------------
-------------------------------------------------------------
   PROCEDURE cabeceraxml(
      p_doc xmldom.domdocument,
      p_trans VARCHAR2,
      p_fixed VARCHAR2,
      p_nrosec VARCHAR2,
      p_nroversion VARCHAR2,
      p_secuencia VARCHAR2,
      p_nodoactual OUT xmldom.domnode) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
   BEGIN
      xmldom.setversion(p_doc, '1.0'' encoding=''ISO-8859-1');
      xmldom.setcharset(p_doc, 'ISO-8859-1');
      mynode := xmldom.makenode(p_doc);
      myelement := xmldom.createelement(p_doc, 'T' || p_trans);
      xmldom.setattribute(myelement, 'xmlns', 'https://ais.bancamarch.es/tr' || p_trans);
      mynode := xmldom.appendchild(mynode, xmldom.makenode(myelement));
      myelement := xmldom.createelement(p_doc, 'Entrada');
      mynode := xmldom.appendchild(mynode, xmldom.makenode(myelement));
      p_nodoactual := mynode;
      myelement := xmldom.createelement(p_doc, 'CabeceraEntrada');
      mynode := xmldom.appendchild(mynode, xmldom.makenode(myelement));
      --
      anadirnodotexto(p_doc, mynode, 'Fixed1', p_fixed);
      anadirnodotexto(p_doc, mynode, 'NroSecuencia', p_nrosec);
      anadirnodotexto(p_doc, mynode, 'NroTransaccion', p_trans);
      anadirnodotexto(p_doc, mynode, 'NroVersion', p_nroversion);
      anadirnodotexto(p_doc, mynode, 'Secuencia', p_secuencia);
   END;

-------------------------------------------------------------
-- Transacción 4200 validación del logon de usuario
--
   PROCEDURE xmllogon(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_logon rlogon_in) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
      anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_logon.empleado);
      anadirnodotexto(p_doc, mynode, 'RpFeOperacion', p_logon.fechaoperacion);
   END;

-------------------------------------------------------------
-- Transacción 4001 búsqueda genérica de clientes
--
   PROCEDURE xmlpersonas(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_personas rpersonas_in) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));

      IF p_formato = 'E0' THEN
         anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
         anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_personas.empleado);
         anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_personas.centroorigen);
         anadirnodotexto(p_doc, mynode, 'RpClaveSip', p_personas.clavesip);
      ELSIF p_formato = 'E1' THEN
         anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
         anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_personas.empleado);
         anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_personas.centroorigen);
         anadirnodotexto(p_doc, mynode, 'RpTipoDocumento', p_personas.tipodocumento);
         anadirnodotexto(p_doc, mynode, 'RpDocIdentif', p_personas.docidentif);
         anadirnodotexto(p_doc, mynode, 'RpPosicionamiento', p_personas.posicionamiento);
      ELSIF p_formato = 'E2' THEN
         anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
         anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_personas.empleado);
         anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_personas.centroorigen);
         anadirnodotexto(p_doc, mynode, 'RpApellido1', p_personas.apellido1);
         anadirnodotexto(p_doc, mynode, 'RpApellido2', p_personas.apellido2);
         anadirnodotexto(p_doc, mynode, 'RpNombrePersona', p_personas.nombrepersona);
         anadirnodotexto(p_doc, mynode, 'RpPosicionamiento', p_personas.posicionamiento);
      END IF;
   END;

-------------------------------------------------------------
-- Transacción 4206 búsqueda información de una persona
--
   PROCEDURE xmlinfpersona(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_personas rpersonas_in) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
      anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_personas.empleado);
      anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_personas.centroorigen);
      anadirnodotexto(p_doc, mynode, 'RpClaveSip', p_personas.clavesip);
   END;

-------------------------------------------------------------
-- Transacción 4201 alta de una póliza
--
   PROCEDURE xmlpoliza(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_poliza rpoliza_in,
      p_tomadores ttomadores) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mynode_tomador xmldom.domnode;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
      anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_poliza.empleado);
      anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_poliza.centroorigen);
      anadirnodotexto(p_doc, mynode, 'RpFeOperacion', p_poliza.fechaoperacion);
      anadirnodotexto(p_doc, mynode, 'RpPlzAplicacion', p_poliza.plzaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpPlzEmpresa', p_poliza.plzempresa);
      anadirnodotexto(p_doc, mynode, 'RpPlzCentro', p_poliza.plzcentro);
      anadirnodotexto(p_doc, mynode, 'RpPlzAfijo', p_poliza.plzafijo);
      anadirnodotexto(p_doc, mynode, 'RpPlzNroContrato', p_poliza.plzncontrato);
      anadirnodotexto(p_doc, mynode, 'RpPlzDigito', p_poliza.plzdigito);
      anadirnodotexto(p_doc, mynode, 'RpProducto', p_poliza.producto);
      anadirnodotexto(p_doc, mynode, 'RpImpNominal', REPLACE(p_poliza.impnominal, ',', '.'));
      anadirnodotexto(p_doc, mynode, 'RpFeEfecto', p_poliza.feefecto);
      anadirnodotexto(p_doc, mynode, 'RpFeVencimiento', p_poliza.fevencimiento);
      anadirnodotexto(p_doc, mynode, 'RpAsoAplicacion', p_poliza.asoaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpAsoEmpresa', p_poliza.asoempresa);
      anadirnodotexto(p_doc, mynode, 'RpAsoCentro', p_poliza.asocentro);
      anadirnodotexto(p_doc, mynode, 'RpAsoAfijo', p_poliza.asoafijo);
      anadirnodotexto(p_doc, mynode, 'RpAsoNroContrato', p_poliza.asoncontrato);
      anadirnodotexto(p_doc, mynode, 'RpAsoDigito', p_poliza.asodigito);
      anadirnodotexto(p_doc, mynode, 'RpVinAplicacion', p_poliza.vinaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpVinEmpresa', p_poliza.vinempresa);
      anadirnodotexto(p_doc, mynode, 'RpVinCentro', p_poliza.vincentro);
      anadirnodotexto(p_doc, mynode, 'RpVinAfijo', p_poliza.vinafijo);
      anadirnodotexto(p_doc, mynode, 'RpVinNroContrato', p_poliza.vinncontrato);
      anadirnodotexto(p_doc, mynode, 'RpVinDigito', p_poliza.vindigito);
      anadirnodotexto(p_doc, mynode, 'RpPais', p_poliza.pais);
      anadirnodotexto(p_doc, mynode, 'RpProvincia', p_poliza.provincia);
      anadirnodotexto(p_doc, mynode, 'RpDistrito', p_poliza.distrito);
      anadirnodotexto(p_doc, mynode, 'RpPoblacion', p_poliza.poblacion);
      anadirnodotexto(p_doc, mynode, 'RpTipoCalle', p_poliza.tipocalle);
      anadirnodotexto(p_doc, mynode, 'RpNombreCalle', p_poliza.nombrecalle);
      anadirnodotexto(p_doc, mynode, 'RpNumeroPuerta', p_poliza.numeropuerta);
      anadirnodotexto(p_doc, mynode, 'RpDatPuerta', p_poliza.otrosdatos);

      FOR i IN 0 .. p_tomadores.LAST LOOP
         myelement := xmldom.createelement(p_doc, p_formato || '_Tbl0');
         mynode_tomador := xmldom.appendchild(mynode, xmldom.makenode(myelement));
         anadirnodotexto(p_doc, mynode_tomador, 'Tbl0_RpClaveSip', p_tomadores(i).clavesip);
      END LOOP;
   END;

-------------------------------------------------------------
-- Transacción 4202 adeudo de un recibo
--
   PROCEDURE xmlrecibo(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_recibo IN rrecibo_in) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mynode_aut     xmldom.domnode;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
      anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_recibo.empleado);
      anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_recibo.centroorigen);
      anadirnodotexto(p_doc, mynode, 'RpFeOperacion', p_recibo.fechaoperacion);
      anadirnodotexto(p_doc, mynode, 'RpICobro', p_recibo.tipocobro);
      anadirnodotexto(p_doc, mynode, 'RpConAplicacion', p_recibo.conaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpConEmpresa', p_recibo.conempresa);
      anadirnodotexto(p_doc, mynode, 'RpConCentro', p_recibo.concentro);
      anadirnodotexto(p_doc, mynode, 'RpConAfijo', p_recibo.conafijo);
      anadirnodotexto(p_doc, mynode, 'RpConNroContrato', p_recibo.conncontrato);
      anadirnodotexto(p_doc, mynode, 'RpConDigito', p_recibo.condigito);
      anadirnodotexto(p_doc, mynode, 'RpIAutorizacion', p_recibo.valautorizacion);
      anadirnodotexto(p_doc, mynode, 'RpFeValor', p_recibo.fechavalor);
      anadirnodotexto(p_doc, mynode, 'RpConcepto', p_recibo.conceptoapunte);
      anadirnodotexto(p_doc, mynode, 'RpImpNominal', REPLACE(p_recibo.importe, ',', '.'));
      anadirnodotexto(p_doc, mynode, 'RpTexto', p_recibo.poliza);
      anadirnodotexto(p_doc, mynode, 'RpPlzAplicacion', p_recibo.plzaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpPlzEmpresa', p_recibo.plzempresa);
      anadirnodotexto(p_doc, mynode, 'RpPlzCentro', p_recibo.plzcentro);
      anadirnodotexto(p_doc, mynode, 'RpPlzAfijo', p_recibo.plzafijo);
      anadirnodotexto(p_doc, mynode, 'RpPlzNroContrato', p_recibo.plzncontrato);
      anadirnodotexto(p_doc, mynode, 'RpPlzDigito', p_recibo.plzdigito);
      anadirnodotexto(p_doc, mynode, 'RpProducto', p_recibo.producto);
      anadirnodotexto(p_doc, mynode, 'RpNumeroMovto', p_recibo.numeromvto);
      anadirnodotexto(p_doc, mynode, 'RpFeValor2', p_recibo.fechaefecto);
      anadirnodotexto(p_doc, mynode, 'RpNaturaleza', p_recibo.naturaleza);
      anadirnodotexto(p_doc, mynode, 'RpConcepto2', p_recibo.conceptoapmvto);
      anadirnodotexto(p_doc, mynode, 'RpImporteMovto',
                      REPLACE(p_recibo.importemvto, ',', '.'));
      anadirnodotexto(p_doc, mynode, 'RpValorProvision',
                      REPLACE(p_recibo.valorprovision, ',', '.'));
      anadirnodotexto(p_doc, mynode, 'RpValorVencto', REPLACE(p_recibo.valorvencim, ',', '.'));
      anadirnodotexto(p_doc, mynode, 'RpValorFallmento',
                      REPLACE(p_recibo.valorfallecim, ',', '.'));
      anadirnodotexto(p_doc, mynode, 'RpAboAplicacion', p_recibo.aboaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpAboEmpresa', p_recibo.aboempresa);
      anadirnodotexto(p_doc, mynode, 'RpAboCentro', p_recibo.abocentro);
      anadirnodotexto(p_doc, mynode, 'RpAboAfijo', p_recibo.aboafijo);
      anadirnodotexto(p_doc, mynode, 'RpAboNroContrato', p_recibo.aboncontrato);
      anadirnodotexto(p_doc, mynode, 'RpAboDigito', p_recibo.abodigito);
      anadirnodotexto(p_doc, mynode, 'RpConceptoApte', p_recibo.aboconceptoapun);

      IF p_formato = 'E1' THEN
         anadirnodotexto(p_doc, mynode, 'RpAutDisponible',
                         REPLACE(p_rec_out.autdisponible, ',', '.'));

         IF p_motaut_out.COUNT() > 0 THEN
            FOR i IN 0 .. p_motaut_out.LAST LOOP
               myelement := xmldom.createelement(p_doc, p_formato || '_Tbl0');
               mynode_aut := xmldom.appendchild(mynode, xmldom.makenode(myelement));
               anadirnodotexto(p_doc, mynode_aut, 'Tbl0_RpAutCodAutoriz',
                               p_motaut_out(i).codautoriz);
            END LOOP;
         END IF;
      END IF;
   END;

-------------------------------------------------------------
-- Transacción 4205 cambio cuenta
--
   PROCEDURE xmlcuenta(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_cuenta IN rcuenta_in) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mynode_aut     xmldom.domnode;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
      anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_cuenta.empleado);
      anadirnodotexto(p_doc, mynode, 'RpCentroOrigen', p_cuenta.centroorigen);
      anadirnodotexto(p_doc, mynode, 'RpFeOperacion', p_cuenta.fechaoperacion);
      anadirnodotexto(p_doc, mynode, 'RpPlzAplicacion', p_cuenta.plzaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpPlzEmpresa', p_cuenta.plzempresa);
      anadirnodotexto(p_doc, mynode, 'RpPlzCentro', p_cuenta.plzcentro);
      anadirnodotexto(p_doc, mynode, 'RpPlzAfijo', p_cuenta.plzafijo);
      anadirnodotexto(p_doc, mynode, 'RpPlzNroContrato', p_cuenta.plzncontrato);
      anadirnodotexto(p_doc, mynode, 'RpPlzDigito', p_cuenta.plzdigito);
      anadirnodotexto(p_doc, mynode, 'CodigoCtaCliente', p_cuenta.cccact);
      anadirnodotexto(p_doc, mynode, 'CccDestino', p_cuenta.cccnou);
   END;

-------------------------------------------------------------
-- Transacción 4203 datos prestamo
--
   PROCEDURE xmlprestamo(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_formato IN VARCHAR2,
      p_prestamo IN rprestamo_in) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mynode_aut     xmldom.domnode;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_formato);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      anadirnodotexto(p_doc, mynode, 'Formato', p_formato);
      anadirnodotexto(p_doc, mynode, 'RpEmpleado', p_prestamo.empleado);
--      anadirNodoTexto(p_doc, myNode, 'RpCentroOrigen', p_prestamo.centroOrigen);
      anadirnodotexto(p_doc, mynode, 'RpFeOperacion', p_prestamo.fechaoperacion);
      anadirnodotexto(p_doc, mynode, 'RpAplicacion', p_prestamo.conaplicacion);
      anadirnodotexto(p_doc, mynode, 'RpConEmpresa', p_prestamo.conempresa);
      anadirnodotexto(p_doc, mynode, 'RpConCentro', p_prestamo.concentro);
      anadirnodotexto(p_doc, mynode, 'RpConAfijo', p_prestamo.conafijo);
      anadirnodotexto(p_doc, mynode, 'RpConNroContrato', p_prestamo.conncontrato);
      anadirnodotexto(p_doc, mynode, 'RpConDigito', p_prestamo.condigito);
      anadirnodotexto(p_doc, mynode, 'RpPosicionamiento', p_prestamo.posicionamiento);
   END;

-------------------------------------------------------------
-- Guardamos el la tabla en memoria los resultados de la consulta
-- Los recuperamos de la estructuraDom generada en el parser
   FUNCTION respuesta_logon(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_out OUT rlogon_out,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_domdoc       xmldom.domdocument;
      v_formato      VARCHAR2(2);
      v_nerror       NUMBER;
      error_respuesta EXCEPTION;
   BEGIN
      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0 THEN
         -- el host ens retorna un error
         RETURN(v_nerror);
      END IF;

      v_formato := buscarnodotexto(v_domdoc, 'Formato');

      IF SUBSTR(v_formato, 2, 1) = '0' THEN
         p_out.centroorigen := buscarnodotexto(v_domdoc, 'RpCentroOrigen');
         p_out.nombrepersona := buscarnodotexto(v_domdoc, 'RpNombrePersona');
      ELSE
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_logon', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151307);   -- error en la respuesta de logon
   END respuesta_logon;

-------------------------------------------------------------
-- Guardamos el la tabla en memoria los resultados de la consulta
-- Los recuperamos de la estructuraDom generada en el parser
   FUNCTION respuesta_personas(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_out OUT tpersonas,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_domdoc       xmldom.domdocument;
      nl             xmldom.domnodelist;
      nlhijos        xmldom.domnodelist;
      len1           NUMBER;
      lenhijos       NUMBER;
      n              xmldom.domnode;
      ntexto         xmldom.domnode;
      valnodo        VARCHAR2(400);
      valtype        VARCHAR2(400);
      valname        VARCHAR2(400);
      v_formato      VARCHAR2(2);
      v_nerror       NUMBER;
      error_respuesta EXCEPTION;
   BEGIN
      p_out.DELETE;
      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0 THEN
         -- el host ens retorna un error
         RETURN(v_nerror);
      END IF;

      v_formato := buscarnodotexto(v_domdoc, 'Formato');

      IF SUBSTR(v_formato, 2, 1) = '2' THEN
         -- Busco el posicionamiento y lo introduzco en la primera posición de la tabla
         p_out(0).posicionamiento := buscarnodotexto(v_domdoc, 'RpPosicionamiento');
         p_out(0).secuencia := buscarnodotexto(v_domdoc, 'Secuencia');
         --
         nl := xmldom.getelementsbytagname(v_domdoc, 'S2_Tbl0');
         len1 := xmldom.getlength(nl);

         FOR j IN 0 .. len1 - 1 LOOP
            n := xmldom.item(nl, j);
            nlhijos := xmldom.getchildnodes(n);
            lenhijos := xmldom.getlength(nlhijos);

            FOR i IN 0 .. lenhijos - 1 LOOP
               n := xmldom.item(nlhijos, i);
               valname := xmldom.getnodename(n);
               valtype := xmldom.getnodetype(n);
               ntexto := xmldom.getfirstchild(n);

               IF NOT xmldom.isnull(ntexto) THEN
                  valnodo := xmldom.getnodevalue(ntexto);
               ELSE
                  valnodo := NULL;
               END IF;

               IF UPPER(valname) = 'TBL0_RPCLAVESIP' THEN
--<MANTIS3937>   p_out(j).clavesip:= to_number(valnodo);
                  p_out(j).clavesip := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPTIPODOCUMENTO' THEN
                  p_out(j).tipodocumento := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPDOCIDENTIF' THEN
                  p_out(j).docidentif := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPAPELLIDO1' THEN
                  p_out(j).apellido1 := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPAPELLIDO2' THEN
                  p_out(j).apellido2 := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPNOMBREPERSONA' THEN
                  p_out(j).nombrepersona := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPTIPOPERSONA' THEN
                  p_out(j).tipopersona := TO_NUMBER(valnodo);
               END IF;
            END LOOP;
         END LOOP;
      ELSE
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_personas', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151308);   -- error en la respuesta de personas
   END respuesta_personas;

-------------------------------------------------------------
   FUNCTION respuesta_infpersona(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_out OUT rinfpersona_out,
      p_tfnos OUT ttelefonos,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_domdoc       xmldom.domdocument;
      nl             xmldom.domnodelist;
      nlhijos        xmldom.domnodelist;
      len1           NUMBER(5);
      lenhijos       NUMBER(5);
      n              xmldom.domnode;
      ntexto         xmldom.domnode;
      valnodo        VARCHAR2(400);
      valtype        VARCHAR2(400);
      valname        VARCHAR2(400);
      v_formato      VARCHAR2(2);
      v_nerror       NUMBER;
      error_respuesta EXCEPTION;
   BEGIN
      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0 THEN
         -- el host ens retorna un error
         RETURN(v_nerror);
      END IF;

      v_formato := buscarnodotexto(v_domdoc, 'Formato');

      IF SUBSTR(v_formato, 2, 1) = '2' THEN
         p_out.clavesip := buscarnodotexto(v_domdoc, 'RpClaveSip');
         p_out.tipodocumento := buscarnodotexto(v_domdoc, 'RpTipoDocumento');
         p_out.docidentif := buscarnodotexto(v_domdoc, 'RpDocIdentif');
         p_out.apellido1 := buscarnodotexto(v_domdoc, 'RpApellido1');
         p_out.apellido2 := buscarnodotexto(v_domdoc, 'RpApellido2');
         p_out.nombrepersona := buscarnodotexto(v_domdoc, 'RpNombrePersona');
         p_out.tipopersona := buscarnodotexto(v_domdoc, 'RpTipoPersona');
         p_out.desc_tipopersona := obtener_descripcion('PER', p_out.tipopersona);
         p_out.sector := buscarnodotexto(v_domdoc, 'RpSector');
         p_out.desc_sector := obtener_descripcion('SEC', p_out.sector);
         p_out.sexo := buscarnodotexto(v_domdoc, 'RpSexo');
         p_out.desc_sexo := obtener_descripcion('SEX', p_out.sexo);
         p_out.estadocivil := buscarnodotexto(v_domdoc, 'RpEstadoCivil');
         p_out.desc_estadocivil := obtener_descripcion('ECV', p_out.estadocivil);
         p_out.nacionalidad := buscarnodotexto(v_domdoc, 'RpNacionalidad');
         p_out.fechanacimiento := buscarnodotexto(v_domdoc, 'RpFechaNacimiento');
         p_out.fechaalta := buscarnodotexto(v_domdoc, 'RpFechaAlta');
         p_out.fechabaja := buscarnodotexto(v_domdoc, 'RpFechaBaja');
         --p_out.cnae:=           buscarNodoTexto(v_domdoc ,'RpCnae');
         p_out.cno := buscarnodotexto(v_domdoc, 'RpCno');
         --p_out.sitconcursal:=   buscarNodoTexto(v_domdoc ,'RpSitConcursal');
         p_out.pais := buscarnodotexto(v_domdoc, 'RpPais');
         p_out.codigopostal := buscarnodotexto(v_domdoc, 'RpCodigoPostal');
         p_out.poblacion := buscarnodotexto(v_domdoc, 'RpPoblacion');
         p_out.tipodomicilio := buscarnodotexto(v_domdoc, 'RpTipoDomicilio');
         p_out.nombrecalle := buscarnodotexto(v_domdoc, 'RpNombreCalle');
         p_out.numeropuerta := buscarnodotexto(v_domdoc, 'RpNumeroPuerta');
         p_out.otrosdatos := buscarnodotexto(v_domdoc, 'RpOtrosDatos');
         p_out.web := buscarnodotexto(v_domdoc, 'RpWeb');
         p_out.email := buscarnodotexto(v_domdoc, 'RpEmail');
         p_out.centrogestor := buscarnodotexto(v_domdoc, 'RpCentroGestor');
         p_out.clavegestor := buscarnodotexto(v_domdoc, 'RpClaveGestor');
         p_out.ipersonaoper := buscarnodotexto(v_domdoc, 'RpIpersonaoper');
         --p_out.iinstitucion:=   buscarNodoTexto(v_domdoc ,'RpIInstitucion');
         --p_out.icliente:=       buscarNodoTexto(v_domdoc ,'RpICliente');

         -- Sacamos los telefonos
         nl := xmldom.getelementsbytagname(v_domdoc, 'S2_Tbl0');
         len1 := xmldom.getlength(nl);

         FOR j IN 0 .. len1 - 1 LOOP
            n := xmldom.item(nl, j);
            nlhijos := xmldom.getchildnodes(n);
            lenhijos := xmldom.getlength(nlhijos);

            FOR i IN 0 .. lenhijos - 1 LOOP
               n := xmldom.item(nlhijos, i);
               valname := xmldom.getnodename(n);
               valtype := xmldom.getnodetype(n);
               ntexto := xmldom.getfirstchild(n);

               IF NOT xmldom.isnull(ntexto) THEN
                  valnodo := xmldom.getnodevalue(ntexto);
               ELSE
                  valnodo := NULL;
               END IF;

               IF UPPER(valname) = 'TBL0_RPTIPOTELEFONO' THEN
                  p_tfnos(j).tipotelefono := TO_NUMBER(valnodo);
                  p_tfnos(j).desc_tipotelefono :=
                                           obtener_descripcion('TFN', p_tfnos(j).tipotelefono);
               ELSIF UPPER(valname) = 'TBL0_RPPREFIJOTELEFONO' THEN
                  p_tfnos(j).prefijotelefono := TO_NUMBER(valnodo);
               ELSIF UPPER(valname) = 'TBL0_RPNUMEROTELEFONO' THEN
                  p_tfnos(j).numerotelefono := TO_NUMBER(valnodo);
               END IF;
            END LOOP;
         END LOOP;
      ELSE
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_infpersona', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151309);   -- error en la respuesta de información de persona
   END respuesta_infpersona;

------------------------------------------
   FUNCTION respuesta_poliza(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_domdoc       xmldom.domdocument;
      v_formato      VARCHAR2(2);
      v_nerror       NUMBER;
      error_respuesta EXCEPTION;
   BEGIN
      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0 THEN
         -- el host ens retorna un error
         RETURN(v_nerror);
      END IF;

      v_formato := buscarnodotexto(v_domdoc, 'Formato');

      IF SUBSTR(v_formato, 2, 1) = '0' THEN
         -- Alta de la pòlissa al host correcta
         NULL;
      ELSE
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_poliza', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151310);   -- error en la respuesta de información de poliza
   END respuesta_poliza;

------------------------------------------
   FUNCTION respuesta_recibo(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_aut OUT NUMBER,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      /* p_aut: retorna el resultat del intent de cobrament del rebut:
           0 --> es cobra el rebut
           1 --> el host demana autorització pel cobrament
           2 --> el host denega el cobrament del rebut
           3 --> el host ens retorna un error
           4 --> la resposta del host no és cap de les esperades: error en la resposta
      */
      v_domdoc       xmldom.domdocument;
      v_formato      VARCHAR2(2);
      nl             xmldom.domnodelist;
      nlhijos        xmldom.domnodelist;
      len1           NUMBER(5);
      lenhijos       NUMBER(5);
      n              xmldom.domnode;
      ntexto         xmldom.domnode;
      valnodo        VARCHAR2(400);
      valtype        VARCHAR2(400);
      valname        VARCHAR2(400);
      v_nerror       NUMBER;
      error_respuesta EXCEPTION;
   BEGIN
      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_formato := buscarnodotexto(v_domdoc, 'Formato');
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0
         AND SUBSTR(v_formato, 2, 1) <> 'Z' THEN
         -- el host ens retorna un error
         p_aut := 3;
         RETURN(v_nerror);
      END IF;

      IF SUBSTR(v_formato, 2, 1) = 'Y' THEN
         -- es demana autorització
         p_aut := 1;
         p_rec_out.empleado := buscarnodotexto(v_domdoc, 'RpEmpleado');
         p_rec_out.centroorigen := buscarnodotexto(v_domdoc, 'RpCentroOrigen');
         p_rec_out.feoperacion := buscarnodotexto(v_domdoc, 'RpFeOperacion');
         p_rec_out.autaplicacion := buscarnodotexto(v_domdoc, 'RpAutAplicacion');
         p_rec_out.auttitular := buscarnodotexto(v_domdoc, 'RpAutTitular');
         p_rec_out.autasocentro := buscarnodotexto(v_domdoc, 'RpAutAsocCentro');
         p_rec_out.autdigitoctrl := buscarnodotexto(v_domdoc, 'RpAutDigCrtl');
         p_rec_out.autasocafijo := buscarnodotexto(v_domdoc, 'RpAutAsocAfijo');
         p_rec_out.autcontrato := buscarnodotexto(v_domdoc, 'RpAutContrato');
         p_rec_out.autdigcontrato := buscarnodotexto(v_domdoc, 'RpAutDigContrato');
         p_rec_out.autclaconcepto := buscarnodotexto(v_domdoc, 'RpAutClaConcepto');
         p_rec_out.autreferencia := buscarnodotexto(v_domdoc, 'RpAutReferencia');
         p_rec_out.autclamoneda := buscarnodotexto(v_domdoc, 'RpAutClaMoneda');
         p_rec_out.autimporte := REPLACE(buscarnodotexto(v_domdoc, 'RpAutImporte'), '.', ',');
         p_rec_out.autsigno := buscarnodotexto(v_domdoc, 'RpAutSigno');
         p_rec_out.autfevalor := buscarnodotexto(v_domdoc, 'RpAutFeValor');
         p_rec_out.autfevento := buscarnodotexto(v_domdoc, 'RpAutFeVento');
         p_rec_out.autlimcredito := REPLACE(buscarnodotexto(v_domdoc, 'RpAutLimCredito'), '.',
                                            ',');
         p_rec_out.autlimdescub := REPLACE(buscarnodotexto(v_domdoc, 'RpAutLimDescub'), '.',
                                           ',');
         p_rec_out.autsaldo := REPLACE(buscarnodotexto(v_domdoc, 'RpAutSaldo'), '.', ',');
         p_rec_out.autretenciones := REPLACE(buscarnodotexto(v_domdoc, 'RpAutRetenciones'),
                                             '.', ',');
         p_rec_out.autriesgo := REPLACE(buscarnodotexto(v_domdoc, 'RpAutRiesgo'), '.', ',');
         p_rec_out.autdisponible := REPLACE(buscarnodotexto(v_domdoc, 'RpAutDisponible'), '.',
                                            ',');
---------------
         nl := xmldom.getelementsbytagname(v_domdoc, 'SY_Tbl0');
         len1 := xmldom.getlength(nl);

         FOR j IN 0 .. len1 - 1 LOOP
            n := xmldom.item(nl, j);
            nlhijos := xmldom.getchildnodes(n);
            lenhijos := xmldom.getlength(nlhijos);

            FOR i IN 0 .. lenhijos - 1 LOOP
               n := xmldom.item(nlhijos, i);
               valname := xmldom.getnodename(n);
               valtype := xmldom.getnodetype(n);
               ntexto := xmldom.getfirstchild(n);

               IF NOT xmldom.isnull(ntexto) THEN
                  valnodo := xmldom.getnodevalue(ntexto);
               ELSE
                  valnodo := NULL;
               END IF;

               IF UPPER(valname) = 'TBL0_RPAUTCODAUTORIZ' THEN
                  p_motaut_out(j).codautoriz := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPAUTAMPLIACION' THEN
                  p_motaut_out(j).ampliacion := valnodo;
               ELSIF UPPER(valname) = 'TBL0_RPERRORDENOM' THEN
                  p_motaut_out(j).errordenom := valnodo;
               END IF;
            END LOOP;
         END LOOP;
      ELSIF SUBSTR(v_formato, 2, 1) = '2' THEN
         -- s'ha cobrat
         p_aut := 0;
      ELSIF SUBSTR(v_formato, 2, 1) = 'Z' THEN
         --- es denega el cobrament
         p_aut := 2;
      ELSE
         -- hi ha hagut un error en la resposta
         p_aut := 4;
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_recibo', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151311);   -- error en la respuesta de recibo
   END respuesta_recibo;

------------------------------------------
   FUNCTION respuesta_cuenta(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_domdoc       xmldom.domdocument;
      v_formato      VARCHAR2(2);
      nl             xmldom.domnodelist;
      nlhijos        xmldom.domnodelist;
      len1           NUMBER(5);
      lenhijos       NUMBER(5);
      n              xmldom.domnode;
      ntexto         xmldom.domnode;
      valnodo        VARCHAR2(400);
      valtype        VARCHAR2(400);
      valname        VARCHAR2(400);
      v_nerror       NUMBER;
      error_respuesta EXCEPTION;
   BEGIN
      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0 THEN
         -- el host ens retorna un error
         RETURN(v_nerror);
      END IF;

      v_formato := buscarnodotexto(v_domdoc, 'Formato');

      IF SUBSTR(v_formato, 2, 1) = '0' THEN
         -- Canvi del compte bancari al host correcta
         NULL;
      ELSE
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_cuenta', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151383);   -- error en la respuesta del cambio de cuenta
   END respuesta_cuenta;

-------------------------------------------------------------
   FUNCTION respuesta_prestamo(
      p_parser IN xmlparser.parser,
      p_nrosec IN NUMBER,
      p_out IN OUT rprestamo_out,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_domdoc       xmldom.domdocument;
      nl             xmldom.domnodelist;
      nlhijos        xmldom.domnodelist;
      len1           NUMBER;
      lenhijos       NUMBER;
      n              xmldom.domnode;
      ntexto         xmldom.domnode;
      valnodo        VARCHAR2(400);
      valtype        VARCHAR2(400);
      valname        VARCHAR2(400);
      v_formato      VARCHAR2(2);
      v_nerror       NUMBER;
      num_cuadros_ant NUMBER;
      v_tipoformato  VARCHAR2(2);
      n_tom          NUMBER := 0;
      error_respuesta EXCEPTION;
   BEGIN
      IF p_out.posicionamiento IS NULL THEN
         p_out.cuadroamort.DELETE;
         p_out.titulares.DELETE;
      END IF;

      v_domdoc := xmlparser.getdocument(p_parser);
      -- Busco error
      v_nerror := tratarerror(v_domdoc, p_nrosec, p_error);

      IF v_nerror <> 0 THEN
         -- el host ens retorna un error
         RETURN(v_nerror);
      END IF;

      v_formato := buscarnodotexto(v_domdoc, 'Formato');
      v_tipoformato := SUBSTR(v_formato, 2, 1);

      IF v_tipoformato IN('0', '2') THEN
         -- Busco el posicionamiento y lo introduzco en la primera posición de la tabla
         p_out.posicionamiento := buscarnodotexto(v_domdoc, 'RpPosicionamiento');

         IF v_tipoformato = '0' THEN
            p_out.datospres.tipoamort := buscarnodotexto(v_domdoc, 'RpTipoPrestamo');
            p_out.datospres.tipointeres := buscarnodotexto(v_domdoc, 'TipoInteres');
            p_out.datospres.capital := REPLACE(buscarnodotexto(v_domdoc, 'RpCapital'), '.',
                                               ',');
            p_out.datospres.fechavencimiento := buscarnodotexto(v_domdoc, 'RpFeVencimiento');
            p_out.datospres.tipoprest := buscarnodotexto(v_domdoc, 'RpTGarantia');
            p_out.datospres.fechabaja := buscarnodotexto(v_domdoc, 'RpFechaBaja');
         END IF;

         -- tractem el cuadre d'amortització
         nl := xmldom.getelementsbytagname(v_domdoc, 'S' || v_tipoformato || '_Tbl0');
         len1 := xmldom.getlength(nl);
         num_cuadros_ant := p_out.cuadroamort.COUNT();

         FOR j IN 0 .. len1 - 1 LOOP
            n := xmldom.item(nl, j);
            nlhijos := xmldom.getchildnodes(n);
            lenhijos := xmldom.getlength(nlhijos);

            FOR i IN 0 .. lenhijos - 1 LOOP
               n := xmldom.item(nlhijos, i);
               valname := xmldom.getnodename(n);
               valtype := xmldom.getnodetype(n);
               ntexto := xmldom.getfirstchild(n);

               IF NOT xmldom.isnull(ntexto) THEN
                  valnodo := xmldom.getnodevalue(ntexto);
               ELSE
                  valnodo := NULL;
               END IF;

               IF SUBSTR(UPPER(valname), 6) = 'RPFEVENCIMIENTO' THEN
                  p_out.cuadroamort(j + num_cuadros_ant - n_tom).fechavencimiento := valnodo;
               ELSIF SUBSTR(UPPER(valname), 6) = 'RPCAPITAL' THEN
                  p_out.cuadroamort(j + num_cuadros_ant - n_tom).capital :=
                                                                    REPLACE(valnodo, '.', ',');
               ELSIF SUBSTR(UPPER(valname), 6) = 'RPINTERES' THEN
                  p_out.cuadroamort(j + num_cuadros_ant - n_tom).interes :=
                                                                    REPLACE(valnodo, '.', ',');
               ELSIF SUBSTR(UPPER(valname), 6) = 'RPCAPITALPDTE' THEN
                  p_out.cuadroamort(j + num_cuadros_ant - n_tom).capitalpdte :=
                                                                    REPLACE(valnodo, '.', ',');
               END IF;

               IF UPPER(valname) = 'TBL0_RPCLAVESIP' THEN
                  n_tom := n_tom + 1;
                  p_out.titulares(j).clavesip := valnodo;
               ELSIF UPPER(valname) = 'TBL0_NROORDTITULAR' THEN
                  p_out.titulares(j).nordtitular := valnodo;
               ELSIF UPPER(valname) = 'TBL0_CLDOCUMENTO' THEN
                  p_out.titulares(j).cldocumento := valnodo;
               ELSIF UPPER(valname) = 'TBL0_PRIMERTITULAR' THEN
                  p_out.titulares(j).primertitular := valnodo;
               END IF;
            END LOOP;
         END LOOP;
      ELSE
         RAISE error_respuesta;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN error_respuesta THEN
         p_error := 'Error en el formato del mensaje de respuesta';
         RETURN(151306);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.respuesta_personas', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151427);   -- error en la respuesta de datos del préstamo
   END respuesta_prestamo;

------------------------------------------
   PROCEDURE guardar_log(ptinter IN NUMBER, pmsgin IN VARCHAR2, p_parserout IN xmlparser.parser) IS
      v_domdoc       xmldom.domdocument;
      v_msgin        int_mensajes.tmenin%TYPE := NULL;   --       v_msgin        VARCHAR2(32767) := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_error        NUMBER := 0;
      vcoderr        VARCHAR2(250);
      vcampo         VARCHAR2(250);
      v_dirmail_to   VARCHAR2(100);
      v_dirmail_from VARCHAR2(100);
      vformato       VARCHAR2(100);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF pac_xml_mv.vsinterf IS NULL THEN
         SELECT sinterf.NEXTVAL
           INTO pac_xml_mv.vsinterf
           FROM DUAL;
      END IF;

      IF pmsgin IS NOT NULL THEN
         -- missatge d'anada
         INSERT INTO int_mensajes
                     (sinterf, cinterf, finterf, tmenout, tmenin)
              VALUES (pac_xml_mv.vsinterf, ptinter, f_sysdate, pmsgin, NULL);

         COMMIT;
      ELSE
         -- missatge de tornada
         BEGIN
            v_domdoc := xmlparser.getdocument(p_parserout);
         EXCEPTION
            WHEN OTHERS THEN
               --hi ha hagut algun error a la resposta
               v_msgin := 'ERROR';
         END;

         IF v_msgin IS NULL THEN
            -- no hi ha cap error a la resposta
            xmldom.writetobuffer(v_domdoc, v_msgin);
         ELSE
            v_msgin := NULL;
         END IF;

         -- CPM 31/12/03: només modifiquem el registre que encara no tingui
         --               missatge de tornada.
         UPDATE int_mensajes
            SET tmenin = v_msgin
          WHERE sinterf = pac_xml_mv.vsinterf
            AND tmenin IS NULL;

         COMMIT;

         -- tractem l'error
         -- busquem respostes buides
         IF v_msgin IS NULL THEN
            vcoderr := '0000-Respuesta vacia';
         ELSE
            -- busquem errors de format
            vcoderr := RTRIM(LTRIM(buscarnodotexto(v_domdoc, 'codigo')));

            IF vcoderr IS NOT NULL THEN
               vcoderr := vcoderr || '-Error formato respuesta';
            END IF;

            -- busquem errors en camps concrets retornats pel host
            IF vcoderr IS NULL THEN
               vcoderr := RTRIM(LTRIM(buscarnodotexto(v_domdoc, 'MensError')));

               IF vcoderr IS NOT NULL THEN
                  vcoderr := vcoderr || '-'
                             || RTRIM(LTRIM(buscarnodotexto(v_domdoc, 'DenMensaje')));
               END IF;
            END IF;

            vcampo := RTRIM(LTRIM(buscarnodotexto(v_domdoc, 'NombreCampoError')));
         END IF;

         IF vcoderr IS NOT NULL THEN
            INSERT INTO int_errores
                        (sinterf, ccoderr, ccampo)
                 VALUES (pac_xml_mv.vsinterf, vcoderr, vcampo);

            COMMIT;
            -- tractem l'error en el adeudo, ja que és l'únic tipus de missatge que realitza
            --  transaccions a BM.
            vformato := buscarnodotexto(v_domdoc, 'Formato');

            IF ptinter = '4202'
               AND vformato IS NULL THEN
               v_dirmail_to := f_parinstalacion_t('MAILADEUDO');
               v_dirmail_from := f_parinstalacion_t('MAILERRFROM');
               p_enviar_correo(v_dirmail_from, v_dirmail_to, v_dirmail_from, v_dirmail_to,
                               'Error en el adeudo recibo host sinterf = ' || vsinterf,
                               'Error en el adeudo recibo host sinterf = ' || vsinterf);
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.guardar_log', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
   END;

------------------------------------------
   FUNCTION validacion_logon(p_in IN rlogon_in, p_out OUT rlogon_out, p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      verror := 0;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmllogon(v_domdoc, v_domnode, p_in.formato, p_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
       -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_logon(v_parser, v_nrosecuencia, p_out, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.validacion_logon', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151313);   -- error en la validacion del logon
   END;

-------------------------------------------------------------
   FUNCTION peticion_personas(p_in rpersonas_in, p_out OUT tpersonas, p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmlpersonas(v_domdoc, v_domnode, p_in.formato, p_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
      -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_personas(v_parser, v_nrosecuencia, p_out, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.peticion_personas', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151314);   -- error en la petición personas
   END;

-------------------------------------------------------------
   FUNCTION peticion_infpersona(
      p_in IN rpersonas_in,
      p_out OUT rinfpersona_out,
      p_tfnos OUT ttelefonos,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmlinfpersona(v_domdoc, v_domnode, p_in.formato, p_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
       -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_infpersona(v_parser, v_nrosecuencia, p_out, p_tfnos, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.peticion_infpersonas', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151315);   -- error en la petición de información de personas
   END;

-------------------------------------------------------------
   FUNCTION alta_poliza(p_in IN rpoliza_in, p_tomadores_in IN ttomadores, p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmlpoliza(v_domdoc, v_domnode, p_in.formato, p_in, p_tomadores_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
      -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_poliza(v_parser, v_nrosecuencia, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.alta_poliza', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151316);   -- error en el alta de poliza
   END;

-------------------------------------------------------------
   FUNCTION adeudo_recibo(p_in IN rrecibo_in, p_aut OUT NUMBER, p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmlrecibo(v_domdoc, v_domnode, p_in.formato, p_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
      -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_recibo(v_parser, v_nrosecuencia, p_aut, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.adeudo_recibo', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151317);   -- error en el adeudo recibo
   END;

-------------------------------------------------------------
   FUNCTION cambio_cuenta(p_in IN rcuenta_in, p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmlcuenta(v_domdoc, v_domnode, p_in.formato, p_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
      -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_cuenta(v_parser, v_nrosecuencia, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.cambio_cuenta', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151382);   -- error en el cambio cuenta bancaria
   END;

-------------------------------------------------------------
   FUNCTION datos_prestamo(
      p_in IN rprestamo_in,
      p_out IN OUT rprestamo_out,
      p_error OUT VARCHAR2)
      RETURN NUMBER IS
      v_msg          VARCHAR2(32000);
      v_url          VARCHAR2(500);
      v_nrosecuencia NUMBER(3);
      v_parser       xmlparser.parser;
      v_domdoc       xmldom.domdocument;
      v_domnode      xmldom.domnode;
      verror         NUMBER;
      msgout         VARCHAR2(32000);
   BEGIN
      p_error := NULL;
      -- Generación del xml
      v_domdoc := xmldom.newdomdocument;
      v_nrosecuencia := MOD(TO_NUMBER(TO_CHAR(f_sysdate, 'ss')), 39) + 1;
      cabeceraxml(v_domdoc, p_in.transaccion, 'DTK200', v_nrosecuencia, 1, 0, v_domnode);
      xmlprestamo(v_domdoc, v_domnode, p_in.formato, p_in);
      xmldom.writetobuffer(v_domdoc, v_msg);
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      guardar_log(p_in.transaccion, v_msg, NULL);

      -- Petición al host
      -- Bucaremos la url en una tabla
      BEGIN
         pac_int_online.peticion_host('BM', p_in.transaccion, v_msg, msgout);
         v_parser := pac_int_online.vparser;
      EXCEPTION
         WHEN OTHERS THEN
            --s'ha produit un error a la petició
            pac_int_online.finalizar_parser(v_parser);
            verror := UTL_HTTP.get_detailed_sqlcode;
            p_error := UTL_HTTP.get_detailed_sqlerrm;

            IF p_error IS NOT NULL THEN
               -- guardem el log abans de retornar amb l'error
               guardar_log(p_in.transaccion, NULL, v_parser);
               RETURN verror;
            END IF;
      END;

      guardar_log(p_in.transaccion, NULL, v_parser);
      -- Obtención respuesta
      verror := respuesta_prestamo(v_parser, v_nrosecuencia, p_out, p_error);
      pac_int_online.finalizar_parser(v_parser);
      -- Tratamiento respuesta
      RETURN(verror);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml_mv.datos_prestamo', 1,
                     'Error incontrolado, psinterf: ' || pac_xml_mv.vsinterf, SQLERRM);
         p_error := SQLERRM;
         RETURN(151426);   -- error en los datos del préstamo
   END;

---------------------------------------------------
-- Retorna el valor de los campos que deben mostrarse en la pantalla de
--  autorización del adeudo de un recibo
   PROCEDURE retorno_rec(
      p_auttitular IN OUT VARCHAR2,
      p_autasocentro IN OUT NUMBER,
      p_autdigitoctrl IN OUT NUMBER,
      p_autasocafijo IN OUT NUMBER,
      p_autcontrato IN OUT NUMBER,
      p_autdigcontrato IN OUT NUMBER,
      p_autclaconcepto IN OUT NUMBER,
      p_autclamoneda IN OUT NUMBER,
      p_autimporte IN OUT NUMBER,
      p_autsigno IN OUT NUMBER,
      p_autfevalor IN OUT VARCHAR2,
      p_autfevento IN OUT VARCHAR2,
      p_autlimcredito IN OUT NUMBER,
      p_autlimdescub IN OUT NUMBER,
      p_autsaldo IN OUT NUMBER,
      p_autretenciones IN OUT NUMBER,
      p_autriesgo IN OUT NUMBER,
      p_autdisponible IN OUT NUMBER) IS
   BEGIN
      p_auttitular := pac_xml_mv.p_rec_out.auttitular;
      p_autasocentro := pac_xml_mv.p_rec_out.autasocentro;
      p_autdigitoctrl := pac_xml_mv.p_rec_out.autdigitoctrl;
      p_autasocafijo := pac_xml_mv.p_rec_out.autasocafijo;
      p_autcontrato := pac_xml_mv.p_rec_out.autcontrato;
      p_autdigcontrato := pac_xml_mv.p_rec_out.autdigcontrato;
      p_autclaconcepto := pac_xml_mv.p_rec_out.autclaconcepto;
      p_autclamoneda := pac_xml_mv.p_rec_out.autclamoneda;
      p_autimporte := pac_xml_mv.p_rec_out.autimporte;
      p_autsigno := pac_xml_mv.p_rec_out.autsigno;
      p_autfevalor := pac_xml_mv.p_rec_out.autfevalor;
      p_autfevento := pac_xml_mv.p_rec_out.autfevento;
      p_autlimcredito := pac_xml_mv.p_rec_out.autlimcredito;
      p_autlimdescub := pac_xml_mv.p_rec_out.autlimdescub;
      p_autsaldo := pac_xml_mv.p_rec_out.autsaldo;
      p_autretenciones := pac_xml_mv.p_rec_out.autretenciones;
      p_autriesgo := pac_xml_mv.p_rec_out.autriesgo;
      p_autdisponible := pac_xml_mv.p_rec_out.autdisponible;
   END retorno_rec;

---------------------------------------------------
-- Retorna el valor de los campos del motivo de autorización que deben mostrarse
--  en la pantalla de autorización del adeudo de un recibo
   PROCEDURE retorno_rec_mot(
      p_codautoriz IN OUT VARCHAR2,
      p_errordenom IN OUT VARCHAR2,
      p_ampliacion IN OUT VARCHAR2,
      p_rec IN NUMBER) IS
   BEGIN
      p_codautoriz := pac_xml_mv.p_motaut_out(p_rec).codautoriz;
      p_errordenom := pac_xml_mv.p_motaut_out(p_rec).errordenom;
      p_ampliacion := pac_xml_mv.p_motaut_out(p_rec).ampliacion;
   END retorno_rec_mot;

---------------------------------------------------
-- Retorna el número de motivos de autorización que deben mostrarse en la pantalla de
--  autorización del adeudo de un recibo
   PROCEDURE retorno_num_mot(p_rec IN OUT NUMBER) IS
   BEGIN
      p_rec := pac_xml_mv.p_motaut_out.COUNT;
   END retorno_num_mot;
END pac_xml_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_XML_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_XML_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_XML_MV" TO "PROGRAMADORESCSI";
