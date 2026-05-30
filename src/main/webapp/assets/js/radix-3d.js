(function () {
    const mount = document.getElementById("radix3d");
    if (!mount || typeof THREE === "undefined") {
        return;
    }

    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x0f1f25);

    const camera = new THREE.PerspectiveCamera(52, mount.clientWidth / mount.clientHeight, 0.1, 100);
    camera.position.set(4.5, 3.5, 6);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setSize(mount.clientWidth, mount.clientHeight);
    mount.appendChild(renderer.domElement);

    const group = new THREE.Group();
    scene.add(group);

    const base = new THREE.Mesh(
        new THREE.BoxGeometry(2, 2, 2),
        new THREE.MeshStandardMaterial({ color: 0x15b8a6, roughness: 0.42, metalness: 0.05 })
    );
    group.add(base);

    const rootCurve = new THREE.Mesh(
        new THREE.TorusGeometry(1.7, 0.08, 16, 96, Math.PI * 1.55),
        new THREE.MeshStandardMaterial({ color: 0xf59e0b, emissive: 0x2c1600 })
    );
    rootCurve.rotation.set(Math.PI / 2, 0.1, -0.25);
    rootCurve.position.set(0, -0.1, 0);
    group.add(rootCurve);

    const points = [];
    for (let i = 0; i < 44; i += 1) {
        const t = i / 8;
        points.push(new THREE.Vector3((i - 22) * 0.08, Math.sin(t) * 0.35 + 1.55, Math.cos(t) * 0.35));
    }
    const exponent = new THREE.Mesh(
        new THREE.TubeGeometry(new THREE.CatmullRomCurve3(points), 80, 0.035, 8, false),
        new THREE.MeshStandardMaterial({ color: 0xe85d5a, emissive: 0x240505 })
    );
    group.add(exponent);

    const grid = new THREE.GridHelper(7, 7, 0x88fff1, 0x244851);
    grid.position.y = -1.45;
    scene.add(grid);

    const light = new THREE.DirectionalLight(0xffffff, 1.2);
    light.position.set(4, 6, 5);
    scene.add(light);
    scene.add(new THREE.AmbientLight(0x9ff7ea, 0.55));

    let dragging = false;
    let lastX = 0;

    renderer.domElement.addEventListener("pointerdown", function (event) {
        dragging = true;
        lastX = event.clientX;
        renderer.domElement.setPointerCapture(event.pointerId);
    });

    renderer.domElement.addEventListener("pointermove", function (event) {
        if (!dragging) {
            return;
        }
        const delta = event.clientX - lastX;
        group.rotation.y += delta * 0.01;
        lastX = event.clientX;
    });

    renderer.domElement.addEventListener("pointerup", function () {
        dragging = false;
    });

    window.addEventListener("resize", function () {
        camera.aspect = mount.clientWidth / mount.clientHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(mount.clientWidth, mount.clientHeight);
    });

    function animate() {
        requestAnimationFrame(animate);
        if (!dragging) {
            group.rotation.y += 0.006;
            exponent.rotation.y += 0.01;
        }
        rootCurve.rotation.z += 0.004;
        renderer.render(scene, camera);
    }

    animate();
}());
