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

    function setLocalProgress(id, current, total) {
        const bar = document.getElementById(id);
        if (!bar || !total) {
            return;
        }
        const percent = Math.max(0, Math.min(100, Math.round((current / total) * 100)));
        bar.style.width = percent + "%";
        bar.setAttribute("aria-valuenow", String(percent));
    }

    function shuffle(items) {
        const copy = items.slice();
        for (let i = copy.length - 1; i > 0; i -= 1) {
            const j = Math.floor(Math.random() * (i + 1));
            const temp = copy[i];
            copy[i] = copy[j];
            copy[j] = temp;
        }
        return copy;
    }

    function mathHtml(text) {
        return String(text)
            .replace(/raiz cubica de\s*(\d+)/gi, "&#8731;$1")
            .replace(/raiz de\s*(\d+)/gi, "&radic;$1")
            .replace(/(\d+)\^(\d+)/g, "$1<sup>$2</sup>");
    }

    function setMath(element, text) {
        if (element) {
            element.innerHTML = mathHtml(text);
        }
    }

    function showSignal(type) {
        const signal = document.getElementById("gameSignal");
        if (!signal) {
            return;
        }
        signal.className = "game-signal " + (type === "star" ? "star" : "x");
        signal.textContent = type === "star" ? "★" : "X";
        signal.setAttribute("aria-hidden", "false");
        window.clearTimeout(showSignal.timer);
        showSignal.timer = window.setTimeout(function () {
            signal.className = "game-signal";
            signal.textContent = "";
            signal.setAttribute("aria-hidden", "true");
        }, 900);
    }

    function markStoredProgress() {
        document.querySelectorAll("[data-complete-key]").forEach(function (card) {
            if (completed.has(card.dataset.completeKey)) {
                card.classList.add("game-complete");
                addReplayButton(card);
            }
        });
        updateProgress();
    }

    function addReplayButton(card) {
        if (!card || card.querySelector(".replay-game-btn")) {
            return;
        }
        const button = document.createElement("button");
        button.type = "button";
        button.className = "replay-game-btn";
        button.textContent = "Reiniciar";
        button.addEventListener("click", function () {
            const target = card.id ? "#" + card.id : "";
            window.location.replace(window.location.pathname + window.location.search + target);
            window.location.reload();
        });
        card.appendChild(button);
    }

    function saveMission(form) {
        if (!form) {
            return;
        }
        const body = new URLSearchParams();
        new FormData(form).forEach(function (value, key) {
            body.append(key, value);
        });
        fetch(form.action, {
            method: "POST",
            body: body,
            credentials: "same-origin",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            keepalive: true
        }).catch(function () {
            if (navigator.sendBeacon) {
                navigator.sendBeacon(form.action, body);
            }
        });
    }

    function completeMission(key, card) {
        if (completed.has(key)) {
            addReplayButton(card);
            return;
        }
        completed.add(key);
        updateProgress();
        card.classList.add("game-complete");
        addReplayButton(card);
        showSuccess("Mision completada. Tu progreso se acaba de actualizar.");
        playSound("success");
        saveMission(card.querySelector(".activity-form"));
    }

    function showSuccess(message) {
        const toast = document.getElementById("successToast");
        if (!toast) {
            return;
        }
        toast.textContent = message;
        toast.classList.add("show");
        window.clearTimeout(showSuccess.timer);
        showSuccess.timer = window.setTimeout(function () {
            toast.classList.remove("show");
        }, 3200);
    }

    function celebrateCard(card, feedback, message) {
        if (feedback) {
            feedback.textContent = message;
        }
        card.classList.add("celebrate");
        window.setTimeout(function () {
            card.classList.remove("celebrate");
        }, 800);
        showSuccess(message);
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
                            showSignal("star");
                            if (feedback) {
                                feedback.textContent = "Muy bien. Reto extra correcto: " + solved.size + " de " + buttons.length + ".";
                            }
                            if (solved.size === buttons.length && onComplete) {
                                onComplete();
                            }
                            return;
                        }
                        playSound("error");
                        showSignal("x");
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
        const baseText = document.getElementById("monsterBase");
        const roundText = document.getElementById("monsterRound");
        const goalText = document.getElementById("monsterGoal");
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

        const rounds = shuffle([
            { base: 2, exponent: 5, result: 32 },
            { base: 3, exponent: 3, result: 27 },
            { base: 5, exponent: 2, result: 25 },
            { base: 2, exponent: 4, result: 16 },
            { base: 4, exponent: 2, result: 16 },
            { base: 6, exponent: 2, result: 36 },
            { base: 3, exponent: 4, result: 81 },
            { base: 2, exponent: 6, result: 64 }
        ]);
        let roundIndex = 0;
        let step = 0;
        let power = 1;
        let targetScale = 1;
        let celebration = false;
        const potionSlots = document.querySelectorAll(".potion-row span");

        function render() {
            requestAnimationFrame(render);
            monster.rotation.y += celebration ? 0.06 : 0.012;
            const bounce = Math.sin(Date.now() * 0.006) * (celebration ? 0.16 : 0.04);
            monster.position.y = bounce;
            monster.scale.lerp(new THREE.Vector3(targetScale, targetScale, targetScale), 0.08);
            renderer.render(scene, camera);
        }

        function updateText() {
            const round = rounds[roundIndex];
            valueText.textContent = String(power);
            baseText.textContent = String(round.base);
            roundText.textContent = String(roundIndex + 1);
            setMath(goalText, round.base + "^" + round.exponent);
            potionSlots.forEach(function (slot, index) {
                slot.style.display = index < round.exponent ? "inline-block" : "none";
                slot.classList.toggle("used", index < step);
            });
            feedback.textContent = "Pociones usadas: " + step + " de " + round.exponent + ". Energia actual: " + power + ".";
            setLocalProgress("monsterProgress", roundIndex + (step / round.exponent), rounds.length);
        }

        function resetRound() {
            step = 0;
            power = 1;
            targetScale = 1;
            celebration = false;
            updateText();
        }

        feed.addEventListener("click", function () {
            const round = rounds[roundIndex];
            if (step >= round.exponent) {
                return;
            }
            step += 1;
            power *= round.base;
            targetScale = 1 + (step * 0.18);
            playSound("plop");
            updateText();

            if (step === round.exponent && power === round.result) {
                celebration = true;
                feedback.textContent = "Correcto. " + round.base + " elevado a " + round.exponent + " es " + round.result + ".";
                showSignal("star");
                if (roundIndex < rounds.length - 1) {
                    roundIndex += 1;
                    window.setTimeout(resetRound, 1100);
                    return;
                }
                celebrateCard(card, feedback, "Zorro completado. Resolviste todas las rondas de potencias.");
                speak("Excelente. Completaste todas las rondas de potencias.");
                completeMission(card.dataset.completeKey, card);
            }
        });

        reset.addEventListener("click", function () {
            resetRound();
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
        const areaText = document.getElementById("laserArea");
        const roundText = document.getElementById("laserRound");
        const card = document.getElementById("laserGame");
        if (!canvas) {
            return;
        }

        const ctx = canvas.getContext("2d");
        const rounds = shuffle([
            { area: 144, side: 12 },
            { area: 81, side: 9 },
            { area: 169, side: 13 },
            { area: 225, side: 15 },
            { area: 64, side: 8 },
            { area: 100, side: 10 },
            { area: 121, side: 11 },
            { area: 196, side: 14 }
        ]);
        let roundIndex = 0;
        const square = { x: 170, y: 72, size: 240 };
        const ruler = { x: 70, y: 336, w: 240, h: 42, dragging: false, dx: 0, dy: 0 };

        function applyRound() {
            const round = rounds[roundIndex];
            square.size = round.side * 18;
            square.x = Math.round((canvas.width - square.size) / 2);
            square.y = 66;
            ruler.w = square.size;
            ruler.x = 70;
            ruler.y = 336;
            areaText.textContent = String(round.area);
            roundText.textContent = String(roundIndex + 1);
            feedback.textContent = "Arrastra la regla roja hasta medir un lado de " + round.side + " unidades.";
            setLocalProgress("laserProgress", roundIndex, rounds.length);
            draw();
        }

        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = "#102329";
            ctx.fillRect(0, 0, canvas.width, canvas.height);

            ctx.strokeStyle = "#5eead4";
            ctx.lineWidth = 2;
            const round = rounds[roundIndex];
            for (let i = 0; i <= round.side; i += 1) {
                const p = square.x + (i * square.size / round.side);
                ctx.beginPath();
                ctx.moveTo(p, square.y);
                ctx.lineTo(p, square.y + square.size);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(square.x, square.y + (i * square.size / round.side));
                ctx.lineTo(square.x + square.size, square.y + (i * square.size / round.side));
                ctx.stroke();
            }

            ctx.strokeStyle = "#f59e0b";
            ctx.lineWidth = 5;
            ctx.strokeRect(square.x, square.y, square.size, square.size);
            ctx.fillStyle = "rgba(245, 158, 11, 0.1)";
            ctx.fillRect(square.x, square.y, square.size, square.size);

            ctx.fillStyle = "#ffffff";
            ctx.font = "800 24px Arial";
            ctx.fillText("Area = " + round.area + " bloques", square.x + 12, square.y + Math.max(82, square.size / 2));
            ctx.font = "700 16px Arial";
            ctx.fillText("Encuentra un lado", square.x + 42, square.y + Math.max(112, square.size / 2 + 28));

            ctx.shadowBlur = 22;
            ctx.shadowColor = "#e85d5a";
            ctx.fillStyle = "#e85d5a";
            ctx.fillRect(ruler.x, ruler.y, ruler.w, ruler.h);
            ctx.shadowBlur = 0;
            ctx.fillStyle = "#ffffff";
            ctx.font = "800 18px Arial";
            ctx.fillText("Regla " + round.side + " unidades", ruler.x + 38, ruler.y + 27);

            for (let i = 0; i <= round.side; i += 1) {
                const x = ruler.x + i * (ruler.w / round.side);
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
                const round = rounds[roundIndex];
                feedback.textContent = "Excelente, descubriste que " + round.side + " x " + round.side + " es " + round.area + ".";
                playSound("plop");
                showSignal("star");
                setLocalProgress("laserProgress", roundIndex + 1, rounds.length);
                if (roundIndex < rounds.length - 1) {
                    roundIndex += 1;
                    window.setTimeout(applyRound, 1000);
                    return;
                }
                celebrateCard(card, feedback, "Sombra laser completada. Mediste todos los cuadrados.");
                speak("Excelente. Mediste todos los cuadrados.");
                completeMission(card.dataset.completeKey, card);
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
            applyRound();
        });

        speakButton.addEventListener("click", function () {
            const round = rounds[roundIndex];
            speak("Si el area es " + round.area + ", necesitas un numero que multiplicado por si mismo de " + round.area + ".");
        });

        applyRound();
    }

    function initMachineGame() {
        const drop = document.getElementById("machineDrop");
        const feedback = document.getElementById("machineFeedback");
        const card = document.getElementById("machineGame");
        const chips = document.querySelectorAll(".block-chip");
        const targetText = document.getElementById("machineTarget");
        const targetCopyText = document.getElementById("machineTargetCopy");
        const cubeCountText = document.getElementById("machineCubeCount");
        const roundText = document.getElementById("machineRound");
        if (!drop) {
            return;
        }
        const rounds = shuffle([
            { target: 27, answer: 3, options: [3, 9, 2] },
            { target: 64, answer: 4, options: [3, 4, 8] },
            { target: 125, answer: 5, options: [5, 10, 25] },
            { target: 216, answer: 6, options: [3, 6, 12] },
            { target: 8, answer: 2, options: [2, 4, 8] },
            { target: 343, answer: 7, options: [7, 14, 49] },
            { target: 512, answer: 8, options: [4, 8, 16] },
            { target: 729, answer: 9, options: [3, 9, 27] }
        ]);
        let roundIndex = 0;

        function applyRound() {
            const round = rounds[roundIndex];
            targetText.textContent = String(round.target);
            targetCopyText.textContent = String(round.target);
            cubeCountText.textContent = String(round.target);
            roundText.textContent = String(roundIndex + 1);
            drop.textContent = "Suelta aqui";
            drop.classList.remove("drop-success");
            feedback.textContent = "Elige el bloque que forma un cubo perfecto de " + round.answer + " x " + round.answer + " x " + round.answer + ".";
            setLocalProgress("machineProgress", roundIndex, rounds.length);
            shuffle(round.options).forEach(function (option, index) {
                const chip = chips[index];
                chip.dataset.value = String(option);
                chip.textContent = "Bloque " + option;
            });
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
            const round = rounds[roundIndex];
            if (Number(value) === round.answer) {
                feedback.textContent = "Correcto. " + round.answer + " x " + round.answer + " x " + round.answer + " forma " + round.target + ".";
                drop.textContent = "Raiz cubica: " + round.answer;
                drop.classList.add("drop-success");
                playSound("plop");
                showSignal("star");
                setLocalProgress("machineProgress", roundIndex + 1, rounds.length);
                if (roundIndex < rounds.length - 1) {
                    roundIndex += 1;
                    window.setTimeout(applyRound, 1000);
                    return;
                }
                celebrateCard(card, feedback, "Maquina completada. Calibraste todos los cubos.");
                speak("Correcto. Calibraste todos los cubos.");
                completeMission(card.dataset.completeKey, card);
                return;
            }
            playSound("error");
            showSignal("x");
            feedback.textContent = "Ese bloque no forma un cubo perfecto de " + round.target + ". Intenta otra vez.";
            card.classList.remove("shake");
            window.setTimeout(function () {
                card.classList.add("shake");
            }, 10);
        }
        applyRound();
    }

    function initCompareGame() {
        const card = document.getElementById("compareGame");
        const feedback = document.getElementById("compareFeedback");
        const equation = document.getElementById("compareEquation");
        const roundText = document.getElementById("compareRound");
        if (!card) {
            return;
        }

        const rounds = shuffle([
            { left: "2^6", leftValue: 64, right: "6^2", rightValue: 36 },
            { left: "5^2", leftValue: 25, right: "3^3", rightValue: 27 },
            { left: "4^3", leftValue: 64, right: "7^2", rightValue: 49 },
            { left: "10^2", leftValue: 100, right: "9^2", rightValue: 81 },
            { left: "2^8", leftValue: 256, right: "7^3", rightValue: 343 },
            { left: "12^2", leftValue: 144, right: "5^3", rightValue: 125 },
            { left: "3^5", leftValue: 243, right: "15^2", rightValue: 225 },
            { left: "4^4", leftValue: 256, right: "8^2", rightValue: 64 }
        ]);
        let index = 0;
        const choices = card.querySelectorAll(".portal-choice");

        function renderRound() {
            const round = rounds[index];
            const shuffled = Math.random() > 0.5
                ? [
                    { label: round.left, value: round.leftValue },
                    { label: round.right, value: round.rightValue }
                ]
                : [
                    { label: round.right, value: round.rightValue },
                    { label: round.left, value: round.leftValue }
                ];
            const max = Math.max(round.leftValue, round.rightValue);
            setMath(equation, round.left + " vs " + round.right);
            roundText.textContent = String(index + 1);
            setLocalProgress("compareProgress", index, rounds.length);
            choices.forEach(function (choice, choiceIndex) {
                choice.classList.remove("portal-open");
                choice.dataset.correct = String(shuffled[choiceIndex].value === max);
                setMath(choice.querySelector("span"), shuffled[choiceIndex].label);
                choice.querySelector("strong").textContent = String(shuffled[choiceIndex].value);
            });
            feedback.textContent = "Toca el portal con mayor energia.";
        }

        choices.forEach(function (choice) {
            choice.addEventListener("click", function () {
                if (choice.dataset.correct === "true") {
                    choice.classList.add("portal-open");
                    playSound("plop");
                    showSignal("star");
                    feedback.textContent = "Correcto. Ese portal tiene mas energia.";
                    setLocalProgress("compareProgress", index + 1, rounds.length);
                    if (index < rounds.length - 1) {
                        index += 1;
                        window.setTimeout(renderRound, 700);
                        return;
                    }
                    celebrateCard(card, feedback, "Portal completado. Comparaste todas las rondas.");
                    speak("Excelente. Completaste todos los portales.");
                    completeMission(card.dataset.completeKey, card);
                    return;
                }
                playSound("error");
                showSignal("x");
                feedback.textContent = "Ese portal tiene menos energia. Mira el resultado y prueba otra vez.";
                card.classList.remove("shake");
                window.setTimeout(function () {
                    card.classList.add("shake");
                }, 10);
            });
        });
        renderRound();
    }

    function initMemoryGame() {
        const card = document.getElementById("memoryGame");
        const board = document.getElementById("memoryBoard");
        const feedback = document.getElementById("memoryFeedback");
        const levelText = document.getElementById("memoryLevel");
        if (!card || !board) {
            return;
        }

        let selected = null;
        let solved = new Set();
        let level = 0;
        const levels = shuffle([
            [["2^3", "8"], ["raiz de 49", "7"], ["4^2", "16"]],
            [["3^2", "9"], ["raiz de 64", "8"], ["2^5", "32"]],
            [["5^2", "25"], ["raiz de 81", "9"], ["3^3", "27"]],
            [["10^2", "100"], ["raiz de 121", "11"], ["2^6", "64"]],
            [["4^3", "64"], ["raiz cubica de 125", "5"], ["6^2", "36"]],
            [["7^2", "49"], ["raiz de 144", "12"], ["2^7", "128"]],
            [["9^2", "81"], ["raiz cubica de 216", "6"], ["5^3", "125"]],
            [["11^2", "121"], ["raiz de 169", "13"], ["3^4", "81"]],
            [["12^2", "144"], ["raiz cubica de 8", "2"], ["10^3", "1000"]],
            [["2^8", "256"], ["raiz de 225", "15"], ["6^3", "216"]]
        ]);

        function renderLevel() {
            board.innerHTML = "";
            selected = null;
            solved = new Set();
            levelText.textContent = String(level + 1);
            feedback.textContent = "Nivel " + (level + 1) + ": encuentra los 3 pares.";
            setLocalProgress("memoryProgress", level, levels.length);

            const cards = [];
            levels[level].forEach(function (pair, pairIndex) {
                cards.push({ pair: String(pairIndex), text: pair[0] });
                cards.push({ pair: String(pairIndex), text: pair[1] });
            });
            cards.sort(function () { return Math.random() - 0.5; });
            cards.forEach(function (item) {
                const button = document.createElement("button");
                button.type = "button";
                button.dataset.pair = item.pair;
                button.innerHTML = mathHtml(item.text);
                board.appendChild(button);
            });
        }

        board.addEventListener("click", function (event) {
            const button = event.target.closest("button");
            if (!button || !board.contains(button)) {
                return;
            }
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
                showSignal("star");
                feedback.textContent = "Par encontrado: " + solved.size + " de 3.";
                setLocalProgress("memoryProgress", level + (solved.size / 3), levels.length);
                if (solved.size === 3) {
                    if (level < levels.length - 1) {
                        feedback.textContent = "Nivel superado. Preparando el siguiente...";
                        level += 1;
                        window.setTimeout(renderLevel, 850);
                        return;
                    }
                    celebrateCard(card, feedback, "Mapa completo. Superaste los 10 niveles.");
                    completeMission(card.dataset.completeKey, card);
                }
                return;
            }
            playSound("error");
            showSignal("x");
            selected.classList.remove("selected");
            selected = null;
            feedback.textContent = "No hacen pareja. Intenta con otra combinacion.";
        });
        renderLevel();
    }

    function initTowerGame() {
        const card = document.getElementById("towerGame");
        const range = document.getElementById("towerRange");
        const exponentText = document.getElementById("towerExponent");
        const valueText = document.getElementById("towerValue");
        const stack = document.getElementById("towerStack");
        const feedback = document.getElementById("towerFeedback");
        const levelText = document.getElementById("towerLevel");
        const targetText = document.getElementById("towerTarget");
        if (!card || !range) {
            return;
        }
        const targets = shuffle([
            { exponent: 2, value: 100 },
            { exponent: 3, value: 1000 },
            { exponent: 4, value: 10000 },
            { exponent: 2, value: 100 },
            { exponent: 5, value: 100000 },
            { exponent: 1, value: 10 },
            { exponent: 4, value: 10000 },
            { exponent: 3, value: 1000 }
        ]);
        let level = 0;
        let towerDone = false;

        function updateTower() {
            if (towerDone) {
                return;
            }
            const exponent = Number(range.value);
            const value = Math.pow(10, exponent);
            const target = targets[level];
            exponentText.textContent = String(exponent);
            valueText.textContent = String(value);
            stack.style.setProperty("--tower-height", String(26 + exponent * 22) + "%");
            levelText.textContent = String(level + 1);
            targetText.textContent = String(target.value);
            setLocalProgress("towerProgress", level + Math.min(1, exponent / target.exponent), targets.length);

            if (exponent === target.exponent) {
                playSound("plop");
                showSignal("star");
                feedback.textContent = "Perfecto. Construiste " + target.value + " unidades.";
                setLocalProgress("towerProgress", level + 1, targets.length);
                if (level < targets.length - 1) {
                    level += 1;
                    window.setTimeout(function () {
                        range.value = "1";
                        updateTower();
                    }, 900);
                    return;
                }
                towerDone = true;
                celebrateCard(card, feedback, "Torre completada. El panda llego a todas las metas.");
                speak("Perfecto. Completaste todas las torres.");
                completeMission(card.dataset.completeKey, card);
                return;
            }
            if (exponent > target.exponent) {
                showSignal("x");
            }
            feedback.textContent = "Ahora tienes " + value + " unidades. Busca exactamente " + target.value + ".";
        }

        range.addEventListener("input", updateTower);
        updateTower();
    }

    function initLakeGame() {
        const card = document.getElementById("lakeGame");
        const feedback = document.getElementById("lakeFeedback");
        const targetText = document.getElementById("lakeTarget");
        const hintText = document.getElementById("lakeBaseHint");
        const roundText = document.getElementById("lakeRound");
        const water = card ? card.querySelector(".lake-water") : null;
        if (!card) {
            return;
        }
        const rounds = shuffle([
            { target: 8, exponent: 3, answer: 2, fish: [3, 5, 6, 2] },
            { target: 27, exponent: 3, answer: 3, fish: [2, 3, 4, 9] },
            { target: 16, exponent: 2, answer: 4, fish: [4, 2, 8, 6] },
            { target: 81, exponent: 2, answer: 9, fish: [7, 9, 3, 5] },
            { target: 125, exponent: 3, answer: 5, fish: [2, 4, 5, 10] },
            { target: 64, exponent: 3, answer: 4, fish: [4, 6, 8, 2] },
            { target: 36, exponent: 2, answer: 6, fish: [3, 6, 9, 12] },
            { target: 49, exponent: 2, answer: 7, fish: [2, 5, 7, 14] }
        ]);
        let index = 0;
        const fishButtons = card.querySelectorAll(".fish");

        function renderRound() {
            const round = rounds[index];
            targetText.textContent = String(round.target);
            if (water) {
                water.dataset.target = String(round.target);
            }
            hintText.textContent = Array(round.exponent).fill("?").join(" x ");
            roundText.textContent = String(index + 1);
            feedback.textContent = "Busca el pez con el numero " + round.answer + ".";
            setLocalProgress("lakeProgress", index, rounds.length);
            shuffle(round.fish).forEach(function (option, fishIndex) {
                const fish = fishButtons[fishIndex];
                fish.textContent = String(option);
                fish.dataset.value = String(option);
                fish.classList.remove("caught", "wrong");
            });
        }

        fishButtons.forEach(function (fish) {
            fish.addEventListener("click", function () {
                const round = rounds[index];
                if (Number(fish.dataset.value) === round.answer) {
                    fish.classList.add("caught");
                    playSound("plop");
                    showSignal("star");
                    hintText.textContent = Array(round.exponent).fill(round.answer).join(" x ");
                    feedback.textContent = "Correcto. " + hintText.textContent + " = " + round.target + ".";
                    setLocalProgress("lakeProgress", index + 1, rounds.length);
                    if (index < rounds.length - 1) {
                        index += 1;
                        window.setTimeout(renderRound, 950);
                        return;
                    }
                    celebrateCard(card, feedback, "Laguna completada. Pescaste todas las bases.");
                    speak("Excelente. Pescaste todas las bases correctas.");
                    completeMission(card.dataset.completeKey, card);
                    return;
                }
                fish.classList.add("wrong");
                playSound("error");
                showSignal("x");
                feedback.textContent = "Ese pez no forma " + round.target + ". Mira cuantos factores necesita el lago.";
                window.setTimeout(function () {
                    fish.classList.remove("wrong");
                }, 650);
            });
        });
        renderRound();
    }

    markStoredProgress();
    initMonsterGame();
    initLaserGame();
    initMachineGame();
    initCompareGame();
    initMemoryGame();
    initTowerGame();
    initLakeGame();
}());
