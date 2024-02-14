import sys

from matplotlib import pyplot as plt

print(sys.argv)
name = sys.argv[1]
f = open(name, "r")


def parse_time(t):
    s, ms = map(float, t.split(':'))
    return s * 100 + ms


data = {}
current_episode = None
f.readline()
while True:
    line = f.readline()
    if not line:
        break
    if line.split(":")[-1] == " \n":
        current_episode = int(line[:-3])
        data[current_episode] = []
    else:
        data[current_episode].append(parse_time(line))

average_times = {episode: sum(times) / len(times) for episode, times in data.items()}

episodes = list(average_times.keys())
averages = list(average_times.values())

plt.figure(figsize=(10, 6))
plt.plot(episodes, averages, marker='o')
plt.title('Average Time per Episode')
plt.xlabel('Episode Number')
plt.ylabel('Average Time (seconds)')
plt.xticks(episodes)
plt.grid(True)
plt.savefig("pic_"+name+".png")
