AI = {
    Name = 'AI: M28',
    Version = '1',
    AIList = {
        {
            key = 'm28ai', --need to update index.lua in aibrains folder hook with the keys of all ais being added
            name = 'AI: BlackOps Adaptive',
            rating = 1100,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aie',
            name = 'AI: BlackOps Easy',
            rating = 850,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aiair',
            name = 'AI: BlackOps Air',
            rating = 1000,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28ailand',
            name = 'AI: BlackOps Land',
            rating = 1000,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28airush',
            name = 'AI: BlackOps Rush',
            rating = 1000,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.8,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 0.9,  -- 20x20
                [2048] = 0.8, -- 40x40
                [4096] = 0.7,  -- 80x80
            }
        },
        {
            key = 'm28aitech',
            name = 'AI: BlackOps Tech',
            rating = 900,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aiturtle',
            name = 'AI: BlackOps Turtle',
            rating = 800,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28ainavy',
            name = 'AI: BlackOps Navy',
            rating = 800,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28airandom',
            name = 'AI: BlackOps Random',
            rating = 800,
            ratingCheatMultiplier = 0.0,
            ratingBuildMultiplier = 0.0,
            ratingOmniBonus = 0,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
    },
    CheatAIList = {
        {
            key = 'm28aicheat', --need to update index.lua in aibrains folder hook with the keys of all ais being added
            name = 'AIx: BlackOps Adaptive',
            rating = 1100,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aiecheat',
            name = 'AIx: BlackOps Easy',
            rating = 850,
            ratingCheatMultiplier = 1100.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 800.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28aiaircheat',
            name = 'AIx: BlackOps Air',
            rating = 1000,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28ailandcheat',
            name = 'AIx: BlackOps Land',
            rating = 1000,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28airushcheat',
            name = 'AIx: BlackOps Rush',
            rating = 1000,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.8,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 0.9,  -- 20x20
                [2048] = 0.8, -- 40x40
                [4096] = 0.7,  -- 80x80
            }
        },
        {
            key = 'm28aitechcheat',
            name = 'AIx: BlackOps Tech',
            rating = 900,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },

        {
            key = 'm28aiturtlecheat', --need to update index.lua in aibrains folder hook with the keys of all ais being added
            name = 'AIx: BlackOps Turtle',
            rating = 800,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28ainavycheat', --need to update index.lua in aibrains folder hook with the keys of all ais being added
            name = 'AIx: BlackOps Navy',
            rating = 800,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
        {
            key = 'm28airandomcheat', --need to update index.lua in aibrains folder hook with the keys of all ais being added
            name = 'AIx: BlackOps Random',
            rating = 800,
            ratingCheatMultiplier = 1300.0, --This is multiplied to the value, so 1.0 will give this amount
            ratingBuildMultiplier = 1000.0,
            ratingNegativeThreshold = 200,
            ratingOmniBonus = 50,
            ratingMapMultiplier = {
                [256] = 0.7895,   -- 5x5 (was 0.778)
                [512] = 1,   -- 10x10
                [1024] = 1.05,  -- 20x20
                [2048] = 1, -- 40x40
                [4096] = 0.9,  -- 80x80
            }
        },
    },
}