<?php
session_start();
if (!isset($_SESSION['usuario'])) {
    header("Location: index.php");
    exit();
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Inicio</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
    <h2 class="mb-4">Bienvenido, <?= htmlspecialchars($_SESSION['usuario']) ?></h2>
    
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="d-grid gap-3">
                <a href="ingresar_socio.php" class="btn btn-outline-primary">Ingresar Socio</a>
                <a href="hacer_prestamo.php" class="btn btn-outline-success">Hacer Préstamo</a>
                <a href="hacer_pago.php" class="btn btn-outline-dark">Hacer Pago</a>
                <hr>
                <a href="logout.php" class="btn btn-outline-danger">Cerrar Sesión</a>
            </div>
        </div>
    </div>
</body>
</html>