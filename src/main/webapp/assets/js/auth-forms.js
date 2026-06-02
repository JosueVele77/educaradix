(function () {
    function paintField(field, force) {
        if (!field || field.type === "hidden") {
            return;
        }
        const hasValue = field.value.trim().length > 0;
        if (!force && !hasValue) {
            field.classList.remove("is-valid-field", "is-invalid-field");
            return;
        }
        field.classList.toggle("is-valid-field", field.checkValidity());
        field.classList.toggle("is-invalid-field", !field.checkValidity());
    }

    document.querySelectorAll("[data-live-validation]").forEach(function (form) {
        const fields = form.querySelectorAll("input[required], input[minlength], input[type='email']");
        fields.forEach(function (field) {
            field.addEventListener("input", function () {
                paintField(field, false);
            });
            field.addEventListener("blur", function () {
                paintField(field, true);
            });
        });

        form.addEventListener("submit", function (event) {
            fields.forEach(function (field) {
                paintField(field, true);
            });
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
        });
    });

    document.querySelectorAll("[data-password-toggle]").forEach(function (button) {
        button.addEventListener("click", function () {
            const input = document.getElementById(button.dataset.passwordToggle);
            if (!input) {
                return;
            }
            const visible = input.type === "text";
            input.type = visible ? "password" : "text";
            button.classList.toggle("is-visible", !visible);
            button.setAttribute("aria-label", visible ? "Mostrar clave" : "Ocultar clave");
        });
    });
}());
