return {
    DATABASE = {
        NAME = "335_dev_eluna",
        CONDITIONS = "spell_overlay_conditions",
        RELATIONS = "spell_overlay_relations",

        SPELLS = {
            CREATE = [[
                CREATE TABLE IF NOT EXISTS %s.`spell_overlay_index` (
                    `id` int(10) NOT NULL,
                    `spell_id` int(10) NOT NULL,
                    `overlay_texture` varchar(150) NOT NULL DEFAULT 'stormyellow-extrabutton',
                    PRIMARY KEY (`id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            ]],
            READ   = "SELECT * FROM %s.spell_bonus_action_index;"
        },
    },

    ENUM = {
        METHOD = { }
    }
}