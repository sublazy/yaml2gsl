# yaml2gsl

yaml2gsl is a tool that allows writing models for GSL code generator in YAML instead of XML. As such, it is not a general-purpose converter. It accepts only very limited YAML schema, and produces XML according to a schema accepted by GSL.

yaml2gsl can take a yaml document like this:
```yaml
scene:
  - meta:
    - version: 1

  - hero:
    - name: Kapyr
    - hp: 100
    - equipment:
      - weapon:
        - type: sword
    - inventory:
      - item:
        - name: bread
      - item:
        - name: dagger
      - item:
        - name: map
      - item:
        - name: gem bag
        - content:
          - emerald
          - ruby
          - emerald
    - effect:
      - name: blessing
      - time_left: 12
    - effect:
      - name: courage
      - time_left: 20

  - hero:
    - name: Anornare
    - hp: 100
    - equipment:
      - ring:
        - material: gold
      - ring:
        - material: copper
    - inventory:
      - item:
        - name: scroll
      - item:
        - name: scroll
      - item:
        - name: mana potion
    - effect:
      - name: focus
      - time_left: 8

  - hero:
    - name: Lyrpen
    - hp: 100
    - effect:
      - name: focus
      - time_left: 8

  - creature:
    - name: Bat
    - hp: 20

  - creature:
    - name: Emu
    - hp: 50
    - effect:
      - name: curse
      - time_left: 2
    - effect:
      - name: haste
      - time_left: 23

  - creature:
    - name: Hobgoblin
    - hp: 80

  - creature:
    - name: Snake
    - hp: 40
```

...And convert it into XML, perfectly suitable for consumption by GSL:
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<scene>
    <meta version = "1" />
    <hero name = "Kapyr" hp = "100">
        <equipment>
            <weapon type = "sword" />
        </equipment>
        <inventory>
            <item name = "bread" />
            <item name = "dagger" />
            <item name = "map" />
            <item name = "gem bag">
                <content />
            </item>
        </inventory>
        <effect name = "blessing" time_left = "12" />
        <effect name = "courage" time_left = "20" />
    </hero>
    <hero name = "Anornare" hp = "100">
        <equipment>
            <ring material = "gold" />
            <ring material = "copper" />
        </equipment>
        <inventory>
            <item name = "scroll" />
            <item name = "scroll" />
            <item name = "mana potion" />
        </inventory>
        <effect name = "focus" time_left = "8" />
    </hero>
    <hero name = "Lyrpen" hp = "100">
        <effect name = "focus" time_left = "8" />
    </hero>
    <creature name = "Bat" hp = "20" />
    <creature name = "Emu" hp = "50">
        <effect name = "curse" time_left = "2" />
        <effect name = "haste" time_left = "23" />
    </creature>
    <creature name = "Hobgoblin" hp = "80" />
    <creature name = "Snake" hp = "40" />
</scene>
```

## Dependencies
 - Ruby
 - https://github.com/ruby/psych

## Problems and Limitations
Note that yaml2gsl is in early development stage. There are probably more problems than useful features.

 - Usability: no command line arguments yet. Input files must be provided in the source file.
 - All the collections must be represented by sequences, i.e. each mapping is allowed to have only one key-value pair. But the value may be a sequence of new mappings, so trees of arbitrary complexity can already be constructed.
 - Sequences of string literals are not supported yet (see contents of the gem bag in the example).

## License
MIT
