(function () {
    const missionCount = document.getElementById("missionCount");
    const missionProgress = document.getElementById("missionProgress");
    const gameShell = document.querySelector(".game-shell");
    const contextPath = gameShell ? gameShell.dataset.context : "";
    const totalMissions = gameShell ? Number(gameShell.dataset.totalMissions || 6) : 6;
    const completed = new Set((gameShell ? gameShell.dataset.completedKeys : "")
        .split(",")
        .map(function (key) { return key.trim(); })
        .filter(Boolean));

    const sounds = {
        plop: new Audio(contextPath + "/assets/audio/plop.wav"),
        success: new Audio(contextPath + "/assets/audio/success.wav"),
        error: new Audio(contextPath + "/assets/audio/error.wav")
    };

    function playSound(name) {
        const sound = sounds[name];
        if (!sound) {
            return;
        }
        sound.currentTime = 0;
        sound.play().catch(function () {});
    }

    function updateProgress() {
        const count = Math.min(completed.size, totalMissions);
        if (missionCount) {
            missionCount.textContent = String(count);
        }
        if (missionProgress) {
            missionProgress.style.width = ((count / totalMissions) * 100) + "%";
        }
    }

    function markStoredProgress() {
        document.querySelectorAll("[data-complete-key]").forEach(function (card) {
            if (completed.has(card.dataset.completeKey)) {
                card.classList.add("game-complete");
            }
        });
        updateProgress();
    }

    function completeMission(key, card) {
        if (completed.has(key)) {
            return;
        }
        completed.add(key);
        updateProgress();
        card.classList.add("game-complete");
        playSound("success");

        const form = card.querySelector(".activity-form");
        if (form) {
            window.setTimeout(function () {
                fetch(form.action, {
                    method: "POST",
                    body: new FormData(form),
                    credentials: "same-origin"
                }).catch(function () {});
            }, 500);
        }
    }

    function initMiniExercises(groupName, answers, feedback, onComplete) {
        const group = document.querySelector('[data-mini-game="' + groupName + '"]');
        if (!group) {
            return function () { return true; };
        }

        const solved = new Set();
        const buttons = group.querySelectorAll("button");
        buttons.forEach(function (button, index) {
            const options = (button.dataset.options || "")
                .split(",")
                .map(function (option) { return option.trim(); })
                .filter(Boolean);

            button.addEventListener("click", function () {
                if (button.classList.contains("solved")) {
                    return;
                }

                group.querySelectorAll(".answer-bubbles").forEach(function (bubbleRow) {
                    bubbleRow.remove();
                });

                const row = document.createElement("div");
                row.className = "answer-bubbles";
                const choices = options.length ? options : [String(answers[index])];
                choices.forEach(function (choice) {
                    const choiceButton = document.createElement("button");
                    choiceButton.type = "button";
                    choiceButton.textContent = choice;
                    choiceButton.addEventListener("click", function () {
                        if (choice.toLowerCase() === String(answers[index]).toLowerCase()) {
                            solved.add(index);
                            button.classList.add("solved");
                            button.textContent = button.textContent.trim() + " = " + answers[index];
                            row.remove();
                            playSound("plop");
                            if (feedback) {
                                feedback.textContent = "Muy bien. Reto extra correcto: " + solved.size + " de " + buttons.length + ".";
                            }
                            if (solved.size === buttons.length && onComplete) {
                                onComplete();
                            }
                            return;
                        }
                        playSound("error");
                        choiceButton.classList.add("wrong");
                        if (feedback) {
                            feedback.textContent = "Prueba otra opcion. Puedes tocar las burbujas hasta encontrarla.";
                        }
                    });
                    row.appendChild(choiceButton);
                });
                button.insertAdjacentElement("afterend", row);
                if (feedback) {
                    feedback.textContent = "Elige la respuesta correcta para " + button.textContent.trim() + ".";
                }
            });
        });

        return function () {
            return solved.size === buttons.length;
        };
    }

    function speak(text) {
        if (!("speechSynthesis" in window)) {
            return;
        }
        window.speechSynthesis.cancel();
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = "es-ES";
        utterance.rate = 0.95;
        window.speechSynthesis.speak(utterance);
    }

    function initMonsterGame() {
        const stage = document.getElementById("monsterStage");
        const feed = document.getElementById("feedMonster");
        const reset = document.getElementById("resetMonster");
        const valueText = document.getElementById("monsterValue");
        const feedback = document.getElementById("monsterFeedback");
        const card = document.getElementById("monsterGame");
        if (!stage || typeof THREE === "undefined") {
            return;
        }

        const scene = new THREE.Scene();
        scene.background = new THREE.Color(0x102329);
        const camera = new THREE.PerspectiveCamera(48, stage.clientWidth / stage.clientHeight, 0.1, 100);
        camera.position.set(0, 2.4, 6.8);

        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        renderer.setSize(stage.clientWidth, stage.clientHeight);
        stage.appendChild(renderer.domElement);

        const monster = new THREE.Group();
        scene.add(monster);

        const bodyMaterial = new THREE.MeshStandardMaterial({ color: 0x5eead4, roughness: 0.35 });
        const bellyMaterial = new THREE.MeshStandardMaterial({ color: 0xfef3c7, roughness: 0.5 });
        const eyeMaterial = new THREE.MeshStandardMaterial({ color: 0xffffff });
        const pupilMaterial = new THREE.MeshStandardMaterial({ color: 0x17212b });
        const hornMaterial = new THREE.MeshStandardMaterial({ color: 0xf59e0b });

        const body = new THREE.Mesh(new THREE.SphereGeometry(1.2, 36, 36), bodyMaterial);
        body.scale.set(1.05, 1.18, 0.95);
        monster.add(body);

        const belly = new THREE.Mesh(new THREE.SphereGeometry(0.62, 28, 28), bellyMaterial);
        belly.position.set(0, -0.18, 0.82);
        belly.scale.set(1, 0.75, 0.25);
        monster.add(belly);

        [-0.42, 0.42].forEach(function (x) {
            const eye = new THREE.Mesh(new THREE.SphereGeometry(0.22, 18, 18), eyeMaterial);
            eye.position.set(x, 0.42, 0.98);
            monster.add(eye);
            const pupil = new THREE.Mesh(new THREE.SphereGeometry(0.09, 12, 12), pupilMaterial);
            pupil.position.set(x, 0.39, 1.14);
            monster.add(pupil);
        });

        [-0.55, 0.55].forEach(function (x) {
            const horn = new THREE.Mesh(new THREE.ConeGeometry(0.2, 0.55, 18), hornMaterial);
            horn.position.set(x, 1.22, 0.05);
            horn.rotation.z = x > 0 ? -0.25 : 0.25;
            monster.add(horn);
        });

        const floor = new THREE.Mesh(
            new THREE.CylinderGeometry(2.6, 2.9, 0.18, 60),
            new THREE.MeshStandardMaterial({ color: 0x1f3d45, roughness: 0.7 })
        );
        floor.position.y = -1.32;
        scene.add(floor);

        scene.add(new THREE.AmbientLight(0xb9fff2, 0.7));
        const light = new THREE.DirectionalLight(0xffffff, 1.1);
        light.position.set(3, 5, 4);
        scene.add(light);

        let step = 0;
        let power = 1;
        let targetScale = 1;
        let celebration = false;
        let coreSolved = completed.has(card.dataset.completeKey);
        const extraSolved = initMiniExercises("monster", [27, 25], feedback, tryComplete);

        function tryComplete() {
            if (coreSolved && extraSolved()) {
                completeMission(card.dataset.completeKey, card);
            }
        }

        function render() {
            requestAnimationFrame(render);
            monster.rotation.y += celebration ? 0.06 : 0.012;
            const bounce = Math.sin(Date.now() * 0.006) * (celebration ? 0.16 : 0.04);
            monster.position.y = bounce;
            monster.scale.lerp(new THREE.Vector3(targetScale, targetScale, targetScale), 0.08);
            renderer.render(scene, camera);
        }

        function updateText() {
            valueText.textContent = String(power);
            feedback.textContent = "Pociones usadas: " + step + " de 5. Tamano actual: " + power + ".";
        }

        feed.addEventListener("click", function () {
            if (step >= 5) {
                return;
            }
            step += 1;
            power *= 2;
            targetScale = 1 + (step * 0.18);
            playSound("plop");
            updateText();

            if (step === 5 && power === 32) {
                celebration = true;
                coreSolved = true;
                feedback.textContent = "El monstruo llego a 32. 2 elevado a 5 es 32.";
                speak("Excelente. El monstruo llego a treinta y dos. Dos elevado a cinco es treinta y dos.");
                tryComplete();
            }
        });

        reset.addEventListener("click", function () {
            step = 0;
            power = 1;
            targetScale = 1;
            celebration = false;
            updateText();
        });

        window.addEventListener("resize", function () {
            camera.aspect = stage.clientWidth / stage.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(stage.clientWidth, stage.clientHeight);
        });

        updateText();
        render();
    }

    function initLaserGame() {
        const canvas = document.getElementById("laserCanvas");
        const reset = document.getElementById("resetRuler");
        const speakButton = document.getElementById("speakRoot");
        const feedback = document.getElementById("laserFeedback");
        const card = document.getElementById("laserGame");
        if (!canvas) {
            return;
        }

        const ctx = canvas.getContext("2d");
        const square = { x: 170, y: 72, size: 240 };
        const ruler = { x: 70, y: 336, w: 240, h: 42, dragging: false, dx: 0, dy: 0 };
        let coreSolved = completed.has(card.dataset.completeKey);
        const extraSolved = initMiniExercises("laser", [9, 13], feedback, tryComplete);

        function tryComplete() {
            if (coreSolved && extraSolved()) {
                completeMission(card.dataset.completeKey, card);
            }
        }

        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = "#102329";
            ctx.fillRect(0, 0, canvas.width, canvas.height);

            ctx.strokeStyle = "#5eead4";
            ctx.lineWidth = 2;
            for (let i = 0; i <= 12; i += 1) {
                const p = square.x + (i * square.size / 12);
                ctx.beginPath();
                ctx.moveTo(p, square.y);
                ctx.lineTo(p, square.y + square.size);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(square.x, square.y + (i * square.size / 12));
                ctx.lineTo(square.x + square.size, square.y + (i * square.size / 12));
                ctx.stroke();
            }

            ctx.strokeStyle = "#f59e0b";
            ctx.lineWidth = 5;
            ctx.strokeRect(square.x, square.y, square.size, square.size);
            ctx.fillStyle = "rgba(245, 158, 11, 0.1)";
            ctx.fillRect(square.x, square.y, square.size, square.size);

            ctx.fillStyle = "#ffffff";
            ctx.font = "800 24px Arial";
            ctx.fillText("Area = 144 bloques", square.x + 12, square.y + 126);
            ctx.font = "700 16px Arial";
            ctx.fillText("Encuentra un lado", square.x + 52, square.y + 154);

            ctx.shadowBlur = 22;
            ctx.shadowColor = "#e85d5a";
            ctx.fillStyle = "#e85d5a";
            ctx.fillRect(ruler.x, ruler.y, ruler.w, ruler.h);
            ctx.shadowBlur = 0;
            ctx.fillStyle = "#ffffff";
            ctx.font = "800 18px Arial";
            ctx.fillText("Regla 12 unidades", ruler.x + 46, ruler.y + 27);

            for (let i = 0; i <= 12; i += 1) {
                const x = ruler.x + i * (ruler.w / 12);
                ctx.strokeStyle = "#ffffff";
                ctx.lineWidth = i % 3 === 0 ? 3 : 1;
                ctx.beginPath();
                ctx.moveTo(x, ruler.y);
                ctx.lineTo(x, ruler.y + (i % 3 === 0 ? 20 : 12));
                ctx.stroke();
            }
        }

        function pointerPosition(event) {
            const rect = canvas.getBoundingClientRect();
            const scaleX = canvas.width / rect.width;
            const scaleY = canvas.height / rect.height;
            return {
                x: (event.clientX - rect.left) * scaleX,
                y: (event.clientY - rect.top) * scaleY
            };
        }

        function checkWin() {
            const closeX = Math.abs(ruler.x - square.x) < 12;
            const closeY = Math.abs(ruler.y - (square.y + square.size + 16)) < 18;
            if (closeX && closeY) {
                ruler.x = square.x;
                ruler.y = square.y + square.size + 16;
                draw();
                coreSolved = true;
                feedback.textContent = "Excelente, descubriste que 12 x 12 es 144.";
                speak("Excelente, descubriste que doce por doce es ciento cuarenta y cuatro.");
                tryComplete();
            }
        }

        canvas.addEventListener("pointerdown", function (event) {
            const p = pointerPosition(event);
            const inside = p.x >= ruler.x && p.x <= ruler.x + ruler.w && p.y >= ruler.y && p.y <= ruler.y + ruler.h;
            if (!inside) {
                return;
            }
            ruler.dragging = true;
            ruler.dx = p.x - ruler.x;
            ruler.dy = p.y - ruler.y;
            canvas.setPointerCapture(event.pointerId);
        });

        canvas.addEventListener("pointermove", function (event) {
            if (!ruler.dragging) {
                return;
            }
            const p = pointerPosition(event);
            ruler.x = Math.max(10, Math.min(canvas.width - ruler.w - 10, p.x - ruler.dx));
            ruler.y = Math.max(10, Math.min(canvas.height - ruler.h - 10, p.y - ruler.dy));
            feedback.textContent = "Busca que la regla mida exactamente el borde del cuadrado.";
            draw();
        });

        canvas.addEventListener("pointerup", function () {
            ruler.dragging = false;
            checkWin();
        });

        reset.addEventListener("click", function () {
            ruler.x = 70;
            ruler.y = 336;
            feedback.textContent = "Arrastra la regla roja sobre el borde iluminado.";
            draw();
        });

        speakButton.addEventListener("click", function () {
            speak("Si el area es ciento cuarenta y cuatro, necesitas un numero que multiplicado por si mismo de ciento cuarenta y cuatro.");
        });

        draw();
    }

    function initMachineGame() {
        const drop = document.getElementById("machineDrop");
        const feedback = document.getElementById("machineFeedback");
        const card = document.getElementById("machineGame");
        const chips = document.querySelectorAll(".block-chip");
        if (!drop) {
            return;
        }
        let coreSolved = completed.has(card.dataset.completeKey);
        const extraSolved = initMiniExercises("machine", [4, 5], feedback, tryComplete);

        function tryComplete() {
            if (coreSolved && extraSolved()) {
                completeMission(card.dataset.completeKey, card);
            }
        }

        chips.forEach(function (chip) {
            chip.addEventListener("dragstart", function (event) {
                event.dataTransfer.setData("text/plain", chip.dataset.value);
            });
            chip.addEventListener("click", function () {
                testValue(chip.dataset.value);
            });
        });

        drop.addEventListener("dragover", function (event) {
            event.preventDefault();
            drop.classList.add("drop-ready");
        });

        drop.addEventListener("dragleave", function () {
            drop.classList.remove("drop-ready");
        });

        drop.addEventListener("drop", function (event) {
            event.preventDefault();
            drop.classList.remove("drop-ready");
            testValue(event.dataTransfer.getData("text/plain"));
        });

        function testValue(value) {
            if (value === "3") {
                coreSolved = true;
                feedback.textContent = "Correcto. 3 x 3 x 3 forma 27, por eso 27^(1/3) = 3.";
                drop.textContent = "Raiz cubica: 3";
                drop.classList.add("drop-success");
                speak("Correcto. Tres por tres por tres forma veintisiete.");
                tryComplete();
                return;
            }
            playSound("error");
            feedback.textContent = "Ese bloque no forma un cubo perfecto de 27. Intenta otra vez.";
            card.classList.remove("shake");
            window.setTimeout(function () {
                card.classList.add("shake");
            }, 10);
        }
    }

    function initCompareGame() {
        const card = document.getElementById("compareGame");
        const feedback = document.getElementById("compareFeedback");
        if (!card) {
            return;
        }

        card.querySelectorAll(".portal-choice").forEach(function (choice) {
            choice.addEventListener("click", function () {
                if (choice.dataset.correct === "true") {
                    choice.classList.add("portal-open");
                    feedback.textContent = "Correcto. 2^6 es 64 y supera a 6^2, que es 36.";
                    speak("Correcto. Dos elevado a seis es sesenta y cuatro.");
                    completeMission(card.dataset.completeKey, card);
                    return;
                }
                playSound("error");
                feedback.textContent = "Ese portal tiene 36 de energia. Busca el que llega a 64.";
                card.classList.remove("shake");
                window.setTimeout(function () {
                    card.classList.add("shake");
                }, 10);
            });
        });
    }

    function initMemoryGame() {
        const card = document.getElementById("memoryGame");
        const board = document.getElementById("memoryBoard");
        const feedback = document.getElementById("memoryFeedback");
        if (!card || !board) {
            return;
        }

        let selected = null;
        const solved = new Set();
        Array.from(board.children)
            .sort(function () { return Math.random() - 0.5; })
            .forEach(function (button) { board.appendChild(button); });

        board.querySelectorAll("button").forEach(function (button) {
            button.addEventListener("click", function () {
                if (button.classList.contains("matched")) {
                    return;
                }
                if (!selected) {
                    selected = button;
                    button.classList.add("selected");
                    feedback.textContent = "Ahora elige su pareja.";
                    return;
                }
                if (selected === button) {
                    selected.classList.remove("selected");
                    selected = null;
                    feedback.textContent = "Selecciona una carta de expresion y luego su resultado.";
                    return;
                }
                if (selected.dataset.pair === button.dataset.pair) {
                    selected.classList.remove("selected");
                    selected.classList.add("matched");
                    button.classList.add("matched");
                    solved.add(button.dataset.pair);
                    selected = null;
                    playSound("plop");
                    feedback.textContent = "Par encontrado: " + solved.size + " de 3.";
                    if (solved.size === 3) {
                        feedback.textContent = "Mapa completo. Todas las expresiones encontraron su resultado.";
                        completeMission(card.dataset.completeKey, card);
                    }
                    return;
                }
                playSound("error");
                selected.classList.remove("selected");
                selected = null;
                feedback.textContent = "No hacen pareja. Intenta con otra combinacion.";
            });
        });
    }

    function initTowerGame() {
        const card = document.getElementById("towerGame");
        const range = document.getElementById("towerRange");
        const exponentText = document.getElementById("towerExponent");
        const valueText = document.getElementById("towerValue");
        const stack = document.getElementById("towerStack");
        const feedback = document.getElementById("towerFeedback");
        if (!card || !range) {
            return;
        }

        function updateTower() {
            const exponent = Number(range.value);
            const value = Math.pow(10, exponent);
            exponentText.textContent = String(exponent);
            valueText.textContent = String(value);
            stack.style.setProperty("--tower-height", String(26 + exponent * 22) + "%");

            if (exponent === 3) {
                feedback.textContent = "Perfecto. 10^3 construye 1000 unidades.";
                speak("Perfecto. Diez elevado a tres es mil.");
                completeMission(card.dataset.completeKey, card);
                return;
            }
            feedback.textContent = "Ahora tienes " + value + " unidades. Busca exactamente 1000.";
        }

        range.addEventListener("input", updateTower);
        updateTower();
    }

    markStoredProgress();
    initMonsterGame();
    initLaserGame();
    initMachineGame();
    initCompareGame();
    initMemoryGame();
    initTowerGame();
}());
