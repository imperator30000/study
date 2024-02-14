import matplotlib.pyplot as plt


file_path = 'points_1'

with open(file_path, 'r') as file:
    lines = file.readlines()

lines = [line.strip() for line in lines if line.strip()]


swap = [float(lines[i]) for i in range(0, len(lines), 3)]
memory = [float(lines[i]) for i in range(1, len(lines), 3)]


time_stamps = [lines[i] for i in range(2, len(lines), 3)]

plt.figure(figsize=(20, 10))
plt.plot(time_stamps, swap, label='Memory')
plt.plot(time_stamps, memory, label='Swap Memory')
plt.xlabel('Time')
plt.ylabel('Memory Size (kB)')
plt.title('Swap and Memory Usage Over Time')
plt.legend()
plt.xticks(rotation=45) 
plt.tight_layout() 
plt.grid(True)
plt.savefig('memory_usage_graph.png')

