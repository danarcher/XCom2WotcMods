# Rebalanced Recovery

This mod rebalances soldier recovery times from wounds, such that lightly
wounded soldiers recover quickly, and no soldier is out of action for over
20 days.

Technical details of XCOM 2 healing, and these changes, follow.

This mod also improves will recovery rates to decrease the amount of time
soldiers spend either tired, shaken or otherwise below maximum will levels.

## Healing

When soldiers return injured, they are assigned a number of wound points. The
points they receive depends on how injured they are as a percentage of their
starting health.

The game consults a "wound severities" table, which gives min-max ranges for
current health and wound points received, at each difficulty level.

It then multiplies this value by a time scalar, which also varies by difficulty level. Hence:

    WoundPoints = WoundSeverity(HealthPercent, Difficulty) * TimeScalar(Difficulty)

All work in the XCOM HQ is done with projects. Injured soldiers are assigned to
heal projects. When the heal project completes, they are at full health,
regardless of their starting health.

Every hour, the soldier's wound points reduce by
`XComHeadquarters_BaseHealRate`, which defaults to 80. As soon as it reaches
zero, the project is complete and the soldier is healed.

Given the base heal rate of 80 points per hour, and a time scalar of 1.0:

Points | Days
------ | ------
1920 | 1 day
3840 | 2 days
5760 | 3 days
9600 | 5 days
19200 | 10 days
28800 | 15 days
38400 | 20 days
13440 | 1 week
26880 | 2 weeks
40320 | 3 weeks
53760 | 4 weeks

## Descriptions

There are also descriptions assigned to each soldier to indicate how wounded
they were, such as "Lightly Wounded", "Wounded" and "Gravely Wounded". These are
drawn from a localized array of descriptive strings.

In WotC, for each difficulty, there is a "wound states" table which lists the
health percentage at which a soldier is considered to have the given wound
state. By default there are three (0-2).

The final wound state is always considered "gravely wounded" even if not
described as such to the player, and affects things such as how many visitors
a soldier is likely to receive in the infirmary(!) and which animation they
play when walking back to the Avenger from the dropship.

## Our Settings

We set:

| Health Loss | Days |
| ----------- | ---- |
| Up to 12.5% health loss | 0-3 days |
| Up to 25% health loss | 2-5 days |
| Up to 50% health loss | 5-10 days |
| Up to 75% health loss | 10-15 days |
| Otherwise | 15-20 days |

for all difficulties.

We also set the time scalar to 1.0 for all difficulties.

We consider less than 5 days to be "lightly wounded", 5 or more days to be
"wounded" and 10 or more days to be "gravely wounded".

## Will Recovery

By default, soldiers take:

- 14 to 20 days to fully recover when Shaken;
- 8 to 12 days to fully recover when Tired; and
- 0 to 16 days to fully recover otherwise.

We set:

- 7 to 10 days to fully recover when Shaken;
- 4 to 6 days to fully recover when Tired; and
- 0 to 8 days to fully recover otherwise.
