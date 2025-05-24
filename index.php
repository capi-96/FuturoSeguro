<?php
session_start();
require_once "conexion.php";


$conexion = new Conectar();
try {
    $dbh = $conexion->Conexion();
    $estado_conexion = "✅ Conexión exitosa a la base de datos";
    $clase_alerta = "alert-success";
} catch (Exception $e) {
    $estado_conexion = "❌ Error de conexión a la base de datos";
    $clase_alerta = "alert-danger";
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $usuario = $_POST['usuario'];
    $contrasena = $_POST['contrasena'];
    
    try {
        $sql = "SELECT * FROM Usuarios WHERE nombre_usuario = ? AND contrasena = ? AND rol_id = (SELECT id FROM Roles WHERE nombre_rol = 'rol_cajero')";
        $stmt = $dbh->prepare($sql);
        $stmt->execute([$usuario, $contrasena]);
        $usuarioEncontrado = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($usuarioEncontrado) {
            $_SESSION['usuario'] = $usuarioEncontrado['nombre_usuario'];
            header("Location: inicio.php");
            exit();
        } else {
            $error = "Credenciales inválidas.";
        }
    } catch (Exception $e) {
        $error = "Error al procesar la solicitud.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login Cajero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
    <div class="alert <?= $clase_alerta ?> mb-4">
        <?= $estado_conexion ?>
    </div>
    
    <h2>Inicio de Sesión - Cajero</h2>
    <?php if (isset($error)): ?>
        <div class="alert alert-danger"><?= $error ?></div>
    <?php endif; ?>
    <form method="POST">
        <div class="mb-3">
            <label class="form-label">Usuario</label>
            <input type="text" name="usuario" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Contraseña</label>
            <input type="password" name="contrasena" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary">Iniciar Sesión</button>
    </form>
</body>
</html>
