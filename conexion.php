<?php
class Conectar {
    protected $dbh;

    public function Conexion() {
        try {
            $conectar = new PDO("sqlsrv:server = tcp:umgdbll.database.windows.net;Database=ProyectoFianalDBll", "vidal", "Abril1996/dos");
            $conectar->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $conectar;
        } catch (Exception $e) {
            die("Error de conexión: " . $e->getMessage());
        }
    }

    public static function ruta() {
       // return "http://localhost/FuturoSeguro/";
       return "https://futuroseguro-dmhdb3cfhkeffaae.australiacentral-01.azurewebsites.net/";
    }

    public static function ruta_Base_menu() {
        //return "/FuturoSeguro/";
        return "/futuroseguro-dmhdb3cfhkeffaae.australiacentral-01.azurewebsites.net/";
    }

    public function testConexion() {
        $conexion = $this->Conexion();
        return $conexion ? true : false;
    }
}
?>